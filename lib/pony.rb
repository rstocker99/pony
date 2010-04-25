require 'rubygems'
require 'mail'
require 'base64'

module Pony
	def self.mail(options)
		raise(ArgumentError, ":to is required") unless options[:to]

		options[:via] = default_delivery_method unless options.has_key?(:via)
		raise(ArgumentError, ":via must be either smtp or sendmail") unless via_possibilities.include?(options[:via])

		options = cross_reference_depricated_fields(options)

		if options.has_key?(:via) && options[:via] == :sendmail
			options[:via_options] ||= {}
			options[:via_options][:location] ||= sendmail_binary
		end

		deliver build_mail(options)
	end

	def self.cross_reference_depricated_fields(options)
		if options.has_key?(:smtp)
			warn depricated_message(:smtp, :via_options)
			options[:via_options] = options.delete(:smtp)
		end

		# cross-reference pony options to be compatible with keys mail expects
		{ :host => :address, :user => :user_name, :auth => :authentication, :tls => :enable_starttls_auto }.each do |key, val|
			if options[:via_options] && options[:via_options].has_key?(key)
				warn depricated_message(key, val)
				options[:via_options][val] = options[:via_options].delete(key)
			end
		end

		if options[:content_type] && options[:content_type] =~ /html/ && !options[:html_body]
			warn depricated_message(:content_type, :html_body)
			options[:html_body] = options[:body]
		end

		return options
	end

	def self.deliver(mail)
		mail.deliver!
	end

	def self.default_delivery_method
		File.executable?(sendmail_binary) ? :sendmail : :smtp
	end

	def self.build_mail(options)
		mail = Mail.new do
			to options[:to]
			from options[:from] || 'pony@unknown'
			cc options[:cc]
			bcc options[:bcc]
			subject options[:subject]
			date options[:date] || Time.now
			message_id options[:message_id]

			if options[:html_body]
				html_part do
					content_type 'text/html; charset=UTF-8'
					body options[:html_body]
				end
			end

			# If we're using attachments, the body needs to be a separate part. If not,
                        # we can just set the body directly.
			if options[:body] && (options[:html_body] || options[:attachments])
				text_part do
					body options[:body]
				end
			elsif options[:body]
				body options[:body]
			end

			delivery_method options[:via], (options.has_key?(:via_options) ? options[:via_options] : {})
                end

		(options[:attachments] || []).each do |name, body|
			# mime-types wants to send these as "quoted-printable"
			if name =~ /\.xlsx$/
				mail.attachments[name] = {
					:content => Base64.encode64(body),
					:transfer_encoding => :base64
				}
			else
				mail.attachments[name] = body
			end
		end

		(options[:headers] ||= {}).each do |key, value|
			mail[key] = value
		end

		mail.charset = options[:charset] if options[:charset] # charset must be set after setting content_type

		mail
	end

	def self.sendmail_binary
		sendmail = `which sendmail`.chomp
		sendmail.empty? ? '/usr/sbin/sendmail' : sendmail
	end

	def self.via_possibilities
		%w(sendmail smtp).map{ |x| x.to_sym }
	end

	def self.depricated_message(method, alternative)
		warning_message = "warning: '#{method}' is deprecated"
		warning_message += "; use '#{alternative}' instead." if alternative
		return warning_message
	end
end
