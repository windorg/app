module Web.Controller.Card where

import Web.Controller.Prelude
import Web.View.Card.Edit
import Web.View.Card.Show
import Web.Controller.Authorization
import Named
import Control.Monad (filterM)
import Web.ViewTypes
import qualified Optics

instance Controller CardController where
    action ShowCardAction { cardId } = do
        accessDeniedUnless =<< userCanView @Card cardId
        card <- fetch cardId
        board <- fetch (get #boardId card)
        cardUpdates <- 
          get #cardUpdates card 
            |> orderByDesc #createdAt
            |> fetch
            >>= filterM (userCanView @CardUpdate . get #id)
        replySets <- forM cardUpdates \c ->
            get #replies c
              |> orderByAsc #createdAt
              |> fetch
              >>= filterM (userCanView @Reply . get #id)
              >>= mapM fetchReplyV
        render ShowView { cardUpdates = zip cardUpdates replySets, .. }

    action EditCardAction { cardId } = do
        accessDeniedUnless =<< userCanEdit @Card cardId
        card <- fetch cardId
        board <- fetch (get #boardId card)
        render EditView { .. }

    action UpdateCardAction { cardId } = do
        accessDeniedUnless =<< userCanEdit @Card cardId
        card <- fetch cardId
        board <- fetch (get #boardId card)
        card
            |> buildCard
            |> ifValid \case
                Left card -> render EditView { .. }
                Right card -> do
                    card <- card |> updateRecord
                    redirectTo ShowCardAction { .. }

    action CreateCardAction { boardId } = do
        accessDeniedUnless =<< userCanEdit @Board boardId
        let card = (newRecord :: Card) |> set #boardId boardId
        card
            |> buildCard
            |> ifValid \case
                Left card -> do
                    setErrorMessage "Card is invalid"
                    redirectTo ShowBoardAction { .. }
                Right card -> do
                    card <- card |> createRecord
                    redirectTo ShowBoardAction { .. }

    action DeleteCardAction { cardId } = do
        accessDeniedUnless =<< userCanEdit @Card cardId
        card <- fetch cardId
        deleteRecord card
        redirectTo ShowBoardAction { boardId = get #boardId card }

buildCard card = card
    |> fill @'["title"]
    |> Optics.set #settings_ CardSettings{
         visibility = if paramOrDefault False "private" then VisibilityPrivate else VisibilityPublic
       }
    