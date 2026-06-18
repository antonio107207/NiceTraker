class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @board      = invitation.board
    @inviter    = invitation.inviter
    @invite_url = invitation_url(@invitation)

    mail(to: @invitation.email, subject: "#{@inviter.display_name} invited you to #{@board.name}")
  end
end
