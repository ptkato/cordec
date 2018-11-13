{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ViewPatterns #-}

module Foundation where

import Import.NoFoundation
import Database.Persist.Sql (ConnectionPool, runSqlPool)
import Yesod.Core.Types     (Logger)
import Yesod.Facebook
import Yesod.Auth.Facebook.ServerSide as YAF
import qualified Facebook             as FB
import Text.Hamlet

data App = App
    { appSettings    :: AppSettings
    , appStatic      :: Static 
    , appConnPool    :: ConnectionPool 
    , appHttpManager :: Manager
    , appLogger      :: Logger
    }

mkYesodData "App" $(parseRoutesFile "config/routes")

instance Yesod App where
    makeLogger = return . appLogger
    
    defaultLayout w = do
        p <- widgetToPageContent $ do
            addStylesheet $ StaticR css_style_css
            setTitle "Cordec"
            w
        msgs <- getMessages
        withUrlRenderer $(hamletFile "templates/default-layout.hamlet")

    isAuthorized (AuthR _)        _ = return Authorized
    isAuthorized (StaticR _)      _ = return Authorized
    isAuthorized CordecLoginR     _ = return Authorized
    isAuthorized CordecSignupR    _ = return Authorized
    isAuthorized HomeR            _ = return Authorized
    isAuthorized _ _ = isAuthenticated
    
    approot = ApprootMaster $ appRoot . appSettings

isAuthenticated :: Handler AuthResult
isAuthenticated = do
    auth <- lookupSession "_USER"
    case auth of
        Just _  -> return Authorized
        Nothing -> return AuthenticationRequired

instance YesodPersist App where
    type YesodPersistBackend App = SqlBackend
    runDB action = do
        master <- getYesod
        runSqlPool action $ appConnPool master

instance YesodAuthPersist App

instance YesodAuth App where
    type AuthId App = UserId

    -- 3rd party auth URLs
    -- Facebook - YAF.facebookLogin
    -- loginHandler = lift $ authLayout $ do
       -- $(whamletFile "templates/foundation/login.hamlet")

    authPlugins _ = [authFacebook ["public_profile", "email"]]

    authenticate _ = do
        manager       <- getsYesod appHttpManager
        accessToken   <- YAF.getUserAccessToken
        user          <- runYesodFbT $ FB.getUser (FB.Id "me") [("fields", "email,name")] accessToken
        (email, name) <- return . liftM2 (,) ((maybe (Left . FB.userId $ user) Right) . FB.userEmail) FB.userName $ user
        result        <- runDB . insertBy $ User (pack . show $ email) name Nothing
        return . Authenticated $ either entityKey id result

    authHttpManager = appHttpManager

instance YesodFacebook App where
    fbCredentials = fbCreds . appSettings
    fbHttpManager = appHttpManager

instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

instance HasHttpManager App where
    getHttpManager = appHttpManager
