{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Login where

import Import
import Database.Persist.Postgresql
import Network.HTTP.Types.Status

formLogin :: FormInput Handler (Text, Text)
formLogin = (,)
    <$> ireq textField "usuario"
    <*> ireq passwordField "senha"

postCordecLoginR :: Handler Html
postCordecLoginR = do
    (e, s) <- (fmap . fmap) return $ runInputPost formLogin
    user   <- runDB . getBy . UniqueUserEmail $ e
    case user of
        Just (Entity uid usr) -> do
            if (userPassword usr == s) then do
                setSession "_USER" . tshow $ fromSqlKey uid
                redirect TudoR
            else notAuthenticated
        _ -> notAuthenticated

formUser :: FormInput Handler User
formUser = User
    <$> ireq emailField "email"
    <*> iopt textField "nome"
    <*> (fmap return $ ireq passwordField "senha")

postCordecSignupR :: Handler Html
postCordecSignupR = do
    user <- runInputPost formUser
    uid <- runDB $ insert user
    setSession "_USER" . tshow $ fromSqlKey uid
    redirect CordecSignupR

getCordecSignupR :: Handler Html
getCordecSignupR = do
    sess <- lookupSession "_USER"
    defaultLayout $ [whamlet|
        <form method="POST" action=@{CordecSignupR}>
            Email: <input type="email" name="email">
            Nome: <input type="text" name="nome">
            Senha: <input type="password" name="senha">
            <button>
                $maybe _ <- sess
                    Atualizar
                $nothing
                    Cadastrar
    |]