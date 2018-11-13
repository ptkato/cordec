{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Cordel where

import Import
import Database.Persist.Postgresql

getTudoR :: Handler Html
getTudoR = do
    cordelList <- runDB $ do
        cordelList <- selectList [] []
        mapM (\cl@(Entity _ c) -> fmap (\s -> (cl, s)) $ get404 $ cordelSubmitter c) cordelList
    defaultLayout [whamlet|
        $forall (Entity _ (Cordel title content _), (User _ mname _)) <- cordelList
            <p>#{show content}
            <small>por
                $maybe name <- mname
                    #{name}
                $nothing
                    anônimo
    |]

formCordel :: UserId -> FormInput Handler Cordel
formCordel uid = Cordel
    <$> ireq textField "titulo"
    <*> ireq textareaField "conteudo"
    <*> pure uid

postEscreverR :: Handler Html
postEscreverR = do
    Just uid <- lookupSession "_USER"
    cordel   <- runInputPost . formCordel . read . unpack $ uid
    cid      <- runDB $ insert cordel
    redirect $ CordelR cid

getCordelR :: CordelId -> Handler Html
getCordelR cid = do
    (Cordel t c _, User _ mn _) <- runDB $ do
        c <- get404 cid
        u <- get404 $ cordelSubmitter c
        return (c, u)
    defaultLayout [whamlet|
        <h1>#{t}
        <small>por
            $maybe n <- mn
                #{n}
            $nothing
                anônimo
        <p>#{c}
    |]