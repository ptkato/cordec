{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Login where

import Import
import Database.Persist.Postgresql

formLogin :: FormInput Handler (Text, Text)
formLogin = (,)
    <$> ireq textField "email"
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

postCordecLogoutR :: Handler Html
postCordecLogoutR = do
    deleteSession "_USER"
    redirect HomeR

formUser :: FormInput Handler User
formUser = User
    <$> ireq emailField "email"
    <*> iopt textField "nome"
    <*> (fmap return $ ireq passwordField "senha")

postCordecSignupR :: Handler Html
postCordecSignupR = do
    u <- lookupSession "_USER"
    case u of
        Just _ -> redirect TudoR
        _ -> do
            user <- runInputPost formUser
            uid <- runDB $ insert user
            setSession "_USER" . tshow $ fromSqlKey uid
            redirect CordecSignupR

getCordecSignupR :: Handler Html
getCordecSignupR = do
    defaultLayout $ [whamlet|
        <div class="row">
            <div class="col-2">
                <img class="img-fluid bottom" src=@{StaticR images_religioso_04_png}>
            <div class="col-8">
                <form method="POST" action=@{CordecSignupR}>
                    <div class="form-group">
                        <label for="email">Email: 
                        <input id="email" class="form-control border-1 border-dark rounded-0" type="email" name="email" required>
                    <div class="form-group">
                        <label for="nome">Nome: 
                        <input id="nome" class="form-control border-1 border-dark rounded-0" type="text" name="nome">
                    <div class="form-group">
                        <label for="senha">Senha:
                        <input id="senha" class="form-control border-1 border-dark rounded-0" type="password" name="senha" required>
                    <button class="btn border-1 border-dark rounded-0">Cadastrar
            <div class="col-2">
                <img class="img-fluid bottom" src=@{StaticR images_maria_bonita_05_png}>
    |]