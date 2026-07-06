namespace :portal do
  desc "Promote a user to super admin. Usage: rake portal:create_super_admin[email@example.com]"
  task :create_super_admin, [:email] => :environment do |_, args|
    email = args[:email] || ENV["EMAIL"]
    abort "Usage: rake portal:create_super_admin[email@example.com]" if email.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    if user.super_admin?
      puts "#{user.email} is already a super admin."
    else
      user.update!(super_admin: true)
      puts "✓ #{user.email} (#{user.display_name}) is now a super admin."
      puts "  Portal access: /manage"
    end
  end

  desc "Revoke super admin from a user. Usage: rake portal:revoke_super_admin[email@example.com]"
  task :revoke_super_admin, [:email] => :environment do |_, args|
    email = args[:email] || ENV["EMAIL"]
    abort "Usage: rake portal:revoke_super_admin[email@example.com]" if email.blank?

    user = User.find_by(email: email)
    abort "User not found: #{email}" unless user

    user.update!(super_admin: false)
    puts "✓ Super admin revoked from #{user.email}."
  end

  desc "List all super admins"
  task list_super_admins: :environment do
    admins = User.super_admins
    if admins.empty?
      puts "No super admins found."
    else
      puts "Super admins (#{admins.count}):"
      admins.each { |u| puts "  - #{u.email} (#{u.display_name})" }
    end
  end
end
