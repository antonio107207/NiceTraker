class BoardInvitationService
  Result = Struct.new(:invitation, :success, :flash_key, :flash_params, keyword_init: true) do
    def success? = success
    def error?   = !success
  end

  def self.call(board:, email:, role:, inviter:)
    new(board:, email:, role:, inviter:).call
  end

  def initialize(board:, email:, role:, inviter:)
    @board   = board
    @email   = email
    @role    = role
    @inviter = inviter
  end

  def call
    if @board.members.exists?(email: @email)
      return Result.new(success: false, flash_key: "flash.already_member",
                        flash_params: { email: @email })
    end

    invitation = @board.invitations.find_or_initialize_by(email: @email, status: :pending)
    invitation.assign_attributes(inviter: @inviter, role: @role)
    invitation.save!

    InvitationMailer.invite(invitation).deliver_later

    Result.new(invitation:, success: true, flash_key: "flash.invitation_sent",
               flash_params: { email: @email })
  end
end
