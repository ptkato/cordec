{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Home where

import Import
import Database.Persist.Postgresql
import Yesod.Auth.Facebook (facebookLogin)

getHomeR :: Handler Html
getHomeR = defaultLayout [whamlet|
    <div class="row">
        <div class="col-6">
            <div class="row">
                <div class="col-4 d-flex align-items-center" style="margin-top:1em">
                    <img class="img-fluid" src=@{StaticR images_pessoas_12_png}>
                <div class="col-4 d-flex align-items-center" style="margin-top:6em">
                    <img class="img-fluid" src=@{StaticR images_pessoas_14_png}>
                <div class="col-4 d-flex align-items-center" style="margin-top:3em">
                    <img class="img-fluid" src=@{StaticR images_pessoas_13_png}>
        <div class="col-6 inicial">
            <div>
                <span class="col-12">O cordel é estilo popular
                <span class="col-12">De poesia impressa
                <span class="col-12">No folhetinho ilustrado
                <span class="col-12">Que está pendurado 
                <span class="col-12">No cordão de lembranças
                <span class="col-12">De amor
                <span class="col-12">Ou sofrimento
                <span class="col-12">Mostrando sempre o que há no coração.
            
            <div>
                <span class="col-12">Com rima,
                <span class="col-12">Métrica e oração
                <span class="col-12">Se conta todo o sertão.
                
            <div>
                <span class="col-12">Literatura de cordel
                <span class="col-12">Patrimônio Imaterial Brasileiro
|]

getConhecaR :: Handler Html
getConhecaR = defaultLayout [whamlet|
    <div class="row">    
        <div class="col-8">
            <p class="font-weight-bold m-0">Plataforma informativa e interativa.
            <p class="font-weight-bold m-0">Compartilhando conteúdo através da construção de cordéis.
            
            <p>O Cordec é uma proposta universitária de interação de compartilhamento 
                de ideias, informação e cultura através do uso da <a href=@{ICordelR} class="text-dark">literatura de cordel</a> 
                no ambiente digital. O projeto teve início em setembro de 2018, quando o cordel 
                passou para o status de <a href=@{PatrimonioR} class="text-dark">Patrimônio Imaterial Brasileiro</a>.
            
            <p>O cordel engloba diversos tipos de manifestações artísticas, como o 
                <a href=@{PodcastR} class="text-dark">repente</a> 
                (música) e a <a href="https://pt.wikipedia.org/wiki/Xilogravura" class="text-dark">xilogravura</a> (pintura), além de 
                ser um meio de preservação da identidade e cultura regionais, perpetuando o folclore e a história.
            
            <p><a href=@{VideoR} class="text-dark">Confira aqui</a> como foi a primeira interação realizada dentro da Fatec Rubens 
                Lara - Faculdade de Tecnologia de Santos.
        <div class="col-4">
            <img class="img-fluid-height bottom" src=@{StaticR images_cactus_18_png}>
|]

getICordelR :: Handler Html
getICordelR = defaultLayout [whamlet|
    <div class="row">    
        <div class="col-12">
            
            <p>Literatura de cordel – também conhecida no Brasil como folheto, literatura popular em verso, 
                ou simplesmente cordel – é um gênero literário popular escrito frequentemente na forma rimada, 
                originado em relatos orais e depois impresso em folhetos. 
            
            <p>Remonta ao século XVI, quando o Renascimento popularizou a impressão de relatos orais, e mantém-se 
                uma forma literária popular no Brasil. O nome tem origem na forma como tradicionalmente os folhetos eram 
                expostos para venda, pendurados em cordas, cordéis ou barbantes em Portugal. No Nordeste do Brasil o nome 
                foi herdado, mas a tradição do barbante não se perpetuou: o folheto brasileiro pode ou não estar exposto em 
                barbantes. Alguns poemas são ilustrados com <a href="https://pt.wikipedia.org/wiki/Xilogravura" class="text-dark">xilogravuras</a>, 
                também usadas nas capas. As estrofes mais comuns são as de dez, oito ou seis versos. 
            
            <p>Os autores, ou cordelistas, recitam esses versos de forma melodiosa e cadenciada, acompanhados de viola, 
                como também fazem leituras ou declamações muito empolgadas e animadas para conquistar os possíveis compradores.
        <div class="col-12">
            <img class="img-fluid" src=@{StaticR images_xilogravura_10_png}>
|]

getPatrimonioR :: Handler Html
getPatrimonioR = defaultLayout [whamlet|
    <div class="row">    
        <div class="col-4">
            <img class="img-fluid-height" src=@{StaticR images_cotidiano_03_png}>
        <div class="col-8">
            <p class="font-weight-bold m-0">Plataforma informativa e interativa.
            <p class="font-weight-bold m-0">Compartilhando conteúdo através da construção de cordéis.
            
            <p>Patrimônio Cultural Imaterial ou Patrimônio Cultural Intangível é uma categoria de
                Patrimônio Cultural definida pela Convenção para a Salvaguarda do Patrimônio Cultural
                Imaterial e adotada pela UNESCO, em 2003. Abrange as expressões culturais e as tradições
                que um grupo de indivíduos preserva em respeito da sua ancestralidade, para as gerações futuras.
            
            <p>São exemplos de Patrimônio Imaterial: os saberes, os modos de fazer, as formas de expressão,
                celebrações, as festas e danças populares, lendas, músicas, costumes e outras tradições.
            
            <p>Em 19 de setembro de 2018, a Literatura de Cordel, que também é ofício e meio de sobrevivência
                para inúmeros cidadãos brasileiros, foi reconhecida pelo Conselho Consultivo do IPHAN (Instituto do
                Patrimônio Histórico e Artístico Nacional) como Patrimônio Cultural Brasileiro.
|]