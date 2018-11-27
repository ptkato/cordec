{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Cordel where

import Import
import Database.Persist.Postgresql
import Yesod.Core.Types (FileInfo (..))
import System.Directory (removeFile, doesFileExist)

getTudoR :: Handler Html
getTudoR = do
    sess <- lookupSession "_USER"
    cordelList <- runDB $ do
        cordelList <- selectList [] [Desc CordelLikes]
        mapM (\cl@(Entity _ c) -> fmap (\s -> (cl, s)) $ get404 $ cordelSubmitter c) cordelList
    defaultLayout [whamlet|
        <div class="row">
            <div class="col-4">
                <div class="row">
                    $maybe _ <- sess
                        <div class="col-12 mb-4">
                            <form method="POST" action=@{EscreverR} enctype="multipart/form-data">
                                    <p class="m-0 xilosa">Novo Cordel
                                    <div class="form">
                                        <div class="input-group m-1">
                                            <input type="text" class="form-control border-1 border-dark rounded-0" placeholder="título" name="titulo" required>
                                            <div class="input-group-append">
                                                <button class="btn btn-sm btn-outline-secondary border-1 border-dark rounded-0">Publicar
                                        <div class="input-group m-1">
                                            <input type="file" accept=".jpeg,.jpg" class="form-control-file border-1 border-dark rounded-0" placeholder="título" name="cordel">
                                        <div class="input-group m-1">
                                            <textarea class="form-control border-1 border-dark rounded-0" placeholder="escreva aqui seu cordel" name="conteudo" required>
                    <p class="xilosa col-12 mt-0">
                        $if sess == Nothing
                            <a class="text-dark" href=@{CordecSignupR}>Cadastre-se aqui</a>, ou imprima e escreva:
                        $else
                            Ou imprima e escreva:
                    $forall x <- xs                                    
                        <div class="col-6">
                            <a target="_blank" href="https://cordec-ptkato.c9users.io/static/cordel-ex/b#{x}.jpg">
                                <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/cordel-ex/b#{x}.jpg">
                    <p class="xilosa col-12">Cordéis
                    $forall y <- ys
                        <div class="col-12 mb-4">
                            <a target="_blank" href="https://cordec-ptkato.c9users.io/static/cordel-ex/l#{y}.jpg">
                                <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/cordel-ex/l#{y}.jpg">
                    $forall w <- ws
                        <div class="col-6 mb-4">
                            <a target="_blank" href="https://cordec-ptkato.c9users.io/static/cordel-ex/c#{w}.jpg">
                                <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/cordel-ex/c#{w}.jpg">
            <div class="col-offset-1 col-8">
                <div class="row">
                    <div class="col-12">    
                        $forall (Entity cid (Cordel title content _ _), (User _ mname _)) <- cordelList
                            <a class="text-dark" href=@{CordelR cid}>
                                <p class="size-fix font-weight-bold mb-0 xilosa">#{title}
                            <span>por 
                                $maybe name <- mname
                                    #{name}
                                $nothing
                                    anônimo
                            <p class="cordel">
                                #{content}
    |] where
        xs = [1..4] :: [Int]
        ys = [1] :: [Int]
        ws = [1..12] :: [Int]

formCordel :: UserId -> FormInput Handler (Cordel, Maybe FileInfo)
formCordel uid = (,) <$> (Cordel
    <$> ireq textField "titulo"
    <*> ireq textareaField "conteudo"
    <*> pure 0
    <*> pure uid)
    <*> iopt fileField "cordel"

postEscreverR :: Handler Html
postEscreverR = do
    Just uid       <- lookupSession "_USER"
    (cordel, file) <- runInputPost . formCordel . toSqlKey . read . unpack $ uid
    cid            <- runDB $ insert cordel
    case file of
        Just f -> liftIO $ fileMove f ("static" </> "cordel" </> (show $ fromSqlKey cid))
        _ -> return ()
    redirect $ CordelR cid

postApagarR :: CordelId -> Handler Html
postApagarR cid = do
    muid <- lookupSession "_USER"
    case muid of
        Just uid -> do
            musr <- runDB $ selectFirst [UserId ==. (toSqlKey . read . unpack $ uid)] []
            case musr of
                Just _ -> do
                    runDB $ deleteCascade cid
                    img <- liftIO $ doesFileExist ("static" </> "cordel" </> (show $ fromSqlKey cid))
                    if img
                        then
                            liftIO $ removeFile ("static" </> "cordel" </> (show $ fromSqlKey cid))
                        else
                            return ()                    
                _ -> return ()
        _ -> return ()
    redirect TudoR
            

getCordelR :: CordelId -> Handler Html
getCordelR cid = do
    sess <- lookupSession "_USER"
    (Cordel t c a s, User _ mn _, like) <- runDB $ do
        c <- get404 cid
        u <- get404 $ cordelSubmitter c
        l <- case sess of
            Just x -> getBy $ UniqueLike (toSqlKey . read . unpack $ x) cid
            _ -> return Nothing
        return (c, u, l)
    dfe <- liftIO . doesFileExist $ "static/cordel/" ++ (show . fromSqlKey $ cid)
    defaultLayout [whamlet|
        <div class="clearfix">
            <h1 class="xilosa size-fix float-left">#{t}
            $maybe x <- sess
                $if x == (pack $ show $ fromSqlKey s)
                    <form class="float-right" method="POST" action=@{ApagarR cid}>
                        <button class="btn btn-link btn-fix text-dark xilosa">Remover
            $maybe _ <- sess
                <form class="float-right" method="POST" action=@{LikeR cid}>
                    <button class="btn btn-link btn-fix text-dark xilosa">
                        $maybe _ <- like
                            Desaprovar ( #{a}
                        $nothing
                            Aprovar ) #{a}
            $nothing
                <button class="float-right btn btn-link btn-fix text-dark xilosa">#{a} aprovações
        <span class="small">
            por 
                $maybe n <- mn
                    #{n}
                $nothing
                    anônimo
        <div class="row">
            $if dfe
                <div class="col-6">
                    <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/cordel/#{fromSqlKey cid}">
            <div class="col-6">
                <p class="cordel">
                    #{c}
                
    |]

getExpoR :: Handler Html
getExpoR = defaultLayout [whamlet|
    <p class="xilosa text-center">Cordéis
    <div class="row">
        $forall y <- ys
            <div class="col-12 mb-4">
                <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/cordel-ex/l#{y}.jpg">
        $forall x <- xs
            <div class="col-6 mb-4">
                <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/cordel-ex/c#{x}.jpg">
|] where
    xs = [1..12] :: [Int]
    ys = [1] :: [Int]

postLikeR :: CordelId -> Handler Html
postLikeR cid = do
    Just uid <- lookupSession "_USER"
    runDB $ do
        i <- insertBy $ Likes (toSqlKey . read . unpack $ uid) cid
        case i of
            Left (Entity lid _) -> do
                delete lid
                update cid [CordelLikes -=. 1]
            _ -> update cid [CordelLikes +=. 1]
    redirect $ CordelR cid