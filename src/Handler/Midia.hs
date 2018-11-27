{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Midia where

import Import
import Database.Persist.Postgresql
import Yesod.Auth.Facebook (facebookLogin)

getPodcastR :: Handler Html
getPodcastR = defaultLayout [whamlet|
    <p>Esse podcast se destina a falar sobre a música, que faz parte também da cultura 
        do cordel. Falamos nele sobre o repente, que vem da cultura nordestina e é feita 
        com rima e instrumentos, como o pandeiro. Para trazer algo mais próximo a região 
        de Santos entrevistamos o Cacau Mc, um Mc da baixada santista que falou um pouco 
        sobre a cultura do Hip Hop e o que ele entende sobre repente, já que os dois ritmos 
        tem a forma "falada" com característica.
    <div class="audio-container">
        <audio controls>
            <source src=@{StaticR podcast_Cordel_Podcast_mp3} type="audio/mp3">
|]

getVideoR :: Handler Html
getVideoR = defaultLayout [whamlet|
    <p>Em setembro de 2018 foi realizada uma intervenção da Faculdade de Tecnologia da 
        Baixada Santista, onde os alunos foram convidados e expressar-se e conhecer melhor 
        a Literatura de Cordel. Confira como foi: 
    <div class="embed-responsive embed-responsive-16by9">
        <iframe class="embed-responsive-item" src="https://www.youtube.com/embed/PPoyek5RVOU" frameborder="0" allow="accelerometer; encrypted-media; gyroscope; picture-in-picture" allowfullscreen>
|]

getImagensR :: Handler Html
getImagensR = defaultLayout [whamlet|
    <p class="xilosa text-center">Galeria da intervenção
    <div class="row">
        $forall x <- xs
            <div class="col-4">
                <img class="img-fluid" src="https://cordec-ptkato.c9users.io/static/photos/#{x}.jpg">
|] where xs = [1..27] :: [Int]

getXilogravuraR :: Handler Html
getXilogravuraR = defaultLayout [whamlet|
    <div class="row">
        <div class="col-4">
            <img class="img-fluid" src=@{StaticR images_xilogravura_2_11_png}>
            <p class="xilosa bottom xilogravura">XILOGRAVURA
        <div class="col-8">
            <p>Xilogravura ou xilografia significa gravura em madeira. É uma 
                antiga técnica, de origem chinesa, em que o artesão utiliza um 
                pedaço de madeira para entalhar um desenho, deixando um relevo a 
                parte que pretende fazer a reprodução. Em seguida, utiliza tinta
                para pintar a parte em relevo do desenho.
            
            <p>Na fase final, é utilizado um tipo de prensa para exercer pressão
                e revelar a imagem no papel ou outro suporte. Um detalhe importante
                é que o desenho sai ao contrário do que foi talhado, o que exige um
                maior trabalho do artesão. <a href="https://www.youtube.com/watch?v=BAaR9UHsUA0" class="text-dark">Veja aqui</a> como é feito.
            
            <p>A xilogravura é muito popular na região Nordeste do Brasil, onde
                estão os mais populares xilogravadores (ou xilógrafos) brasileiros.
                Alguns cordelistas eram também xilogravadores, como por exemplo,
                o pernambucano <a href="https://pt.wikipedia.org/wiki/J._Borges" class="text-dark">J.&nbspBorges</a>
|]