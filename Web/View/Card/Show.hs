module Web.View.Card.Show where
import Web.View.Prelude
import Fmt

data ShowView = ShowView { card :: Card, cardUpdates :: [CardUpdate] }

instance View ShowView where
    html ShowView { .. } = [hsx|
        <nav>
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href={CardsAction}>Cards</a></li>
                <li class="breadcrumb-item active">Show Card</li>
            </ol>
        </nav>
        <h1>{get #title card}</h1>
        {forEach cardUpdates renderCardUpdate}
    |]
      where
        -- TODO render year as well
        renderTimestamp :: _ -> Text
        renderTimestamp time =
            -- February 14th, 18:20
            format "{} {}, {}"
              (timeF "%B" time)
              (dayOfMonthOrdF time)
              (timeF "%R" time)
        
        renderCardUpdate cardUpdate = [hsx|
          <p>
            <span class="text-muted small">
              {renderTimestamp (get #createdAt cardUpdate)}
            </span>
            <br>
            <a href={ShowCardUpdateAction (get #id cardUpdate)}>
              {get #content cardUpdate}
            </a>
          </p>
        |]
