module Web.Controller.Inbox where

import Web.Controller.Prelude
import Web.Controller.Authorization
import Web.View.Inbox.Show

instance Controller InboxController where
    beforeAction = ensureIsUser

    action ShowInboxAction = do
        unreadReplies <- sqlQuery "select * from replies where is_read = false and card_update_id in (select id from card_updates where card_id in (select id from cards where user_id = ?))" (Only currentUserId)
        render InboxView{..}