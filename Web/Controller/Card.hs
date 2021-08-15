module Web.Controller.Card where

import Web.Controller.Prelude
import Web.View.Card.Index
import Web.View.Card.New
import Web.View.Card.Edit
import Web.View.Card.Show

instance Controller CardController where
    action CardsAction = do
        card <- query @Card |> fetch
        render IndexView { .. }

    action NewCardAction = do
        let card = newRecord
        render NewView { .. }

    action ShowCardAction { cardId } = do
        card <- fetch cardId
        board :: Board <- fetch (get #boardId card)
        cardUpdates <- get #cardUpdates card |> orderByDesc #createdAt |> fetch
        render ShowView { .. }

    action EditCardAction { cardId } = do
        card <- fetch cardId
        render EditView { .. }

    action UpdateCardAction { cardId } = do
        card <- fetch cardId
        card
            |> buildCard
            |> ifValid \case
                Left card -> render EditView { .. }
                Right card -> do
                    card <- card |> updateRecord
                    setSuccessMessage "Card updated"
                    redirectTo EditCardAction { .. }

    action CreateCardAction { boardId } = do
        let card = (newRecord :: Card) { boardId = boardId }
        card
            |> fill @'["title"]
            |> ifValid \case
                Left card -> render NewView { .. } 
                Right card -> do
                    card <- card |> createRecord
                    redirectTo ShowBoardAction { .. }

    action DeleteCardAction { cardId } = do
        card <- fetch cardId
        deleteRecord card
        redirectTo ShowBoardAction { boardId = get #boardId card }

buildCard card = card
    |> fill @["title", "boardId"]
