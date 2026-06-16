class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @board      = invitation.board
    @inviter    = invitation.inviter
    @accept_url = accept_invitation_url(@invitation, token: @invitation.token)

    mail(to: @invitation.email, subject: "#{@inviter.display_name} invited you to #{@board.name}")
  end
end
