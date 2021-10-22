module Web.View.CardUpdate.Edit where
import Web.View.Prelude
import Web.Helper.View

data EditView = EditView { owner :: User, board :: Board, card :: Card, cardUpdate :: CardUpdate }

instance View EditView where
    html EditView { .. } = [hsx|
        <nav>
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href={BoardsAction}>Boards</a></li>
                {userCrumb (($) #active False) owner}
                {boardCrumb (($) #active False) board}
                {cardCrumb (($) #active False) card}
                <li class="breadcrumb-item active">Edit update</li>
            </ol>
        </nav>
        <h1>Edit update</h1>
        {renderForm cardUpdate}
    |]

renderForm :: CardUpdate -> Html
renderForm cardUpdate = formFor cardUpdate [hsx|
    {(textareaField #content) {
        disableLabel = True,
        fieldClass = "use-tiptap"
      }
    }
    {submitButton {label = "Save"}}
    <div class="ml-4 custom-control custom-control-inline custom-checkbox">
      <input type="checkbox" class="custom-control-input" name="private" id="private" checked={private}>
      <label class="custom-control-label" for="private">🔒 Private comment</label>
    </div>
|]
  where
    private = case cardUpdate ^. #settings_ % #visibility of
      VisibilityPrivate -> True
      VisibilityPublic -> False