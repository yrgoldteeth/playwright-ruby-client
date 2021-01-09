module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser.py
  define_channel_owner :Browser do
    # @param parent [Playwright::ChannelOwner|Playwright::Connection]
    # @param type [String]
    # @param guid [String]
    # @param initializer [Hash]
    def initialize(parent, type, guid, initializer)
      super
      @contexts = Set.new
      @channel.on('close', method(:handle_close))
    end

    def contexts
      @contexts.map do |context|
        ::Playwright::PlaywrightApi.from_channel_owner(context)
      end
    end

    def connected?
      @connected
    end

    def new_context(**options)
      params = options.dup
      # @see https://github.com/microsoft/playwright/blob/5a2cfdbd47ed3c3deff77bb73e5fac34241f649d/src/client/browserContext.ts#L265
      if params[:viewport] == 0
        params.delete(:viewport)
        params[:noDefaultViewport] = true
      end
      if params[:extraHTTPHeaders]
        # TODO
      end
      if params[:storageState].is_a?(String)
        params[:storageState] = JSON.parse(File.read(params[:storageState]))
      end

      context = @channel.send_message_to_server('newContext', params.compact)
      @contexts << context
      context.browser = self
      context.options = params
      context
    end

    def new_page(*args)
      context = new_context(*args)
      page = context.new_page
      page.owned_context = context
      context.owner_page = page
      page
    end

    def close
      return if @closed_or_closing
      @closed_or_closing = true
      @channel.send_message_to_server('close')
    rescue => err
      raise unless safe_close_error?(err)
    end

    def version
      @initializer['version']
    end

    private

    def handle_close(_ = {})
      @connected = false
      emit(Events::Browser::Disconnected)
      @closed_or_closing = false
    end

    # @param err [Exception]
    def safe_close_error?(err)
      return true if err.is_a?(Transport::AlreadyDisconnectedError)

      [
        'Browser has been closed',
        'Target page, context or browser has been closed',
      ].any? do |closed_message|
        err.message.end_with?(closed_message)
      end
    end
  end
end
