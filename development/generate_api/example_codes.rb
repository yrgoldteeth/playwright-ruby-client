module ExampleCodes
  # Browser
  def example_b8acc529feb6c35ab828780a127d7bf2c079dc7f2847ef251c4c1a33b4197bf9(playwright:)
    firefox = playwright.firefox
    browser = firefox.launch
    begin
      page = browser.new_page
      page.goto("https://example.com")
    ensure
      browser.close
    end
  end

  # Browser#contexts
  def example_7f9edd4a42641957d48081449ceb3c54829485d152db1cc82a82f1f21191b90c(playwright:)
    playwright.webkit.launch do |browser|
      puts browser.contexts.count # => 0
      context = browser.new_context
      puts browser.contexts.count # => 1
    end
  end

  # Browser#new_context
  def example_3661a62dd097b41417b066df731db5f80905ccb40be870c04c44980ee7425f56(playwright:)
    playwright.firefox.launch do |browser| # or "chromium.launch" or "webkit.launch".
      # create a new incognito browser context.
      context = browser.new_context

      # create a new page in a pristine context.
      page = context.new_page()
      page.goto("https://example.com")
    end
  end

  # Browser#start_tracing
  def example_5a1282084821fd9127ef5ca54bdda63cdff46564f3cb20e347317dee260d33b3(browser:, page:)
    browser.start_tracing(page: page, path: "trace.json")
    begin
      page.goto("https://www.google.com")
    ensure
      browser.stop_tracing
    end
  end

  # BrowserContext
  def example_b9d02375c8dbbd86bc9ee14a9333ff363525bbec88d23ff8d8edbfda67301ad2(browser:)
    # create a new incognito browser context
    context = browser.new_context

    # create a new page inside context.
    page = context.new_page
    page.goto("https://example.com")

    # dispose context once it is no longer needed.
    context.close()
  end

  # BrowserContext#add_cookies
  def example_9a397455c0681f67226d5bcb8e14922d2a098e184daa133dc191b17bbf5c603e(browser_context:)
    browser_context.add_cookies([cookie_object1, cookie_object2])
  end

  # BrowserContext#add_init_script
  def example_16af9114b96dcc9b341808b8a5e2eb4bb1fa9541858e8d8432a33a979867ccc8(browser_context:)
    # in your playwright script, assuming the preload.js file is in same directory.
    browser_context.add_init_script(path: "preload.js")
  end

  # BrowserContext#clear_permissions
  def example_de61e349d06a98a38ba9bfccc5708125cd263b7d3a31b9a837eda3db0baac288(browser:)
    context = browser.new_context
    context.grant_permissions(["clipboard-read"])

    # do stuff ..

    context.clear_permissions
  end

  # BrowserContext#expose_binding
  def example_81b90f669e98413d55dfbd74319b8b505b137187a593ed03c46b56125a286201(browser_context:)
    browser_context.expose_binding("pageURL", ->(source) { source[:page].url })
    page = browser_context.new_page

    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML

    page.click("button")
  end

  # BrowserContext#expose_binding
  def example_93e847f70b01456eec429a1ebfaa6b8f5334f4c227fd73e62dd6a7facb48dbbd(browser_context:)
    def print_text(source, element)
      element.text_content
    end

    browser_context.expose_binding("clicked", method(:print_text), handle: true)
    page = browser_context.new_page

    page.content = <<~HTML
    <script>
      document.addEventListener('click', async (event) => {
        alert(await window.clicked(event.target));
      })
    </script>
    <div>Click me</div>
    <div>Or click me</div>
    HTML

    page.click('div')
  end

  # BrowserContext#expose_function
  def example_ed09ff5e8c17b09741f2221b75c3891c550a9bd02835d030532f76d85ec25011(browser_context:)
    require 'digest'

    def sha256(text)
      Digest::SHA256.hexdigest(text)
    end

    browser_context.expose_function("sha256", method(:sha256))
    page = browser_context.new_page()
    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML
    page.click("button")
  end

  # BrowserContext#route
  def example_8bee851cbea1ae0c60fba8361af41cc837666490d20c25552a32f79c4e044721(browser:)
    context = browser.new_context
    page = context.new_page
    context.route("**/*.{png,jpg,jpeg}", ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # BrowserContext#route
  def example_aa8a83c2ddd0d9a327cfce8528c61f52cb5d6ec0f0258e03d73fad5481f15360(browser:)
    context = browser.new_context
    page = context.new_page
    context.route(/\.(png|jpg)$/, ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # BrowserContext#route
  def example_ac637e238bebf237fca2ef4fd8a2ef81644eefcf862b305de633c2fabc3b4721(browser:)
    def handle_route(route, request)
      if request.post_data["my-string"]
        mocked_data = request.post_data.merge({ "my-string" => 'mocked-data'})
        route.fulfill(postData: mocked_data)
      else
        route.continue
      end
    end
    context.route("/api/**", method(:handle_route))
  end

  # BrowserContext#set_geolocation
  def example_12142bb78171e322de3049ac91a332da192d99461076da67614b9520b7cd0c6f(browser_context:)
    browser_context.geolocation = { latitude: 59.95, longitude: 30.31667 }
  end

  # BrowserContext#expect_event
  def example_80ebd2eab628fbcf7b668dcf8abf7f058ec345ba2b67e6cc9330c1710c732240(browser_context:, page:)
    new_page = browser_context.expect_event('page') do
      page.click('button')
    end
  end

  # BrowserType
  def example_554dfa8c71a3e87116c6f226d58cdb57d7993dd5df94e22c8fc74c0f83ef7b50(playwright:)
    chromium = playwright.chromium
    chromium.launch do |browser|
      page = browser.new_page
      page.goto('https://example.com/')

      # other actions

    end
  end

  # BrowserType#launch
  def example_90d6ec37772ce92e29e8942ec516d4859264d02aa9b8b8e6f3a773318f567f90(playwright:)
    browser = playwright.chromium.launch( # or "firefox" or "webkit".
      ignoreDefaultArgs: ["--mute-audio"]
    )

    browser.close
  end

  # Dialog
  def example_c954c35627e62be69e1f138f25d7377b13e18d08039d476946217827fa95db52(page:)
    def handle_dialog(dialog)
      puts "[#{dialog.type}] #{dialog.message}"
      if dialog.message =~ /foo/
        dialog.accept_async
      else
        dialog.dismiss
      end
    end

    page.on("dialog", method(:handle_dialog))
    page.evaluate("confirm('foo')") # will be accepted
    # => [confirm] foo
    page.evaluate("alert('bar')") # will be dismissed
    # => [alert] bar
  end

  # ElementHandle
  def example_5ba38bdc5d9e5ce7cfc9c8841eb0176efbb4690d18962066f9ee67f1e8b7b050(page:)
    page.goto("https://example.com")
    href_element = page.query_selector("a")
    href_element.click
    # ...
  end

  # ElementHandle#bounding_box
  def example_8382aa7cfb42a9a17e348e2f738279f1bd9a038f1ea35cc3cb244cc64d768f93(page:, element_handle:)
    box = element_handle.bounding_box
    page.mouse.click(
      box["x"] + box["width"] / 2,
      box["y"] + box["height"] / 2,
    )
  end

  # ElementHandle#dispatch_event
  def example_3b86add6ce355082cd43f4ac0ba9e69c15960bbd7ca601d0618355fe53aa8902(element_handle:)
    element_handle.dispatch_event("click")
  end

  # ElementHandle#dispatch_event
  def example_6b70ea4cf0c7ae9c82cf0ed22ab0dbbb563e2d1419b35d04aa513cf91f0856f9(page:, element_handle:)
    # note you can only create data_transfer in chromium and firefox
    data_transfer = page.evaluate_handle("new DataTransfer()")
    element_handle.dispatch_event("dragstart", eventInit: { dataTransfer: data_transfer })
  end

  # ElementHandle#eval_on_selector
  def example_f6a83ec555fcf23877c11cf55f02a8c89a7fc11d3324859feda42e592e129f4f(page:)
    tweet_handle = page.query_selector(".tweet")
    tweet_handle.eval_on_selector(".like", "node => node.innerText") # => "100"
    tweet_handle.eval_on_selector(".retweets", "node => node.innerText") # => "10"
  end

  # ElementHandle#eval_on_selector_all
  def example_11b54bf5ec18a0d0ceee0868651bb41ab5cd3afcc6b20d5c44f90d835c8d6f81(page:)
    feed_handle = page.query_selector(".feed")
    feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") # => ["hello!", "hi!"]
  end

  # ElementHandle#select_option
  def example_dc2ce38846b91d234483ed8b915b785ffbd9403213279465acd6605f314fe736(element_handle:)
    # single selection matching the value
    element_handle.select_option(value: "blue")
    # single selection matching both the label
    element_handle.select_option(label: "blue")
    # multiple selection
    element_handle.select_option(value: ["red", "green", "blue"])
  end

  # ElementHandle#select_option
  def example_b4cdd4a1a4d0392c2d430e0fb5fc670df2d728b6907553650690a2d0377662e4(element_handle:)
    # multiple selection for blue, red and second option
    element_handle.select_option(value: "blue", index: 2, label: "red")
  end

  # ElementHandle#type
  def example_2dc9720467640fd8bc581ed65159742e51ff91b209cb176fef8b95f14eaad54e(element_handle:)
    element_handle.type("hello") # types instantly
    element_handle.type("world", delay: 100) # types slower, like a user
  end

  # ElementHandle#type
  def example_d13faaf53454653ce45371b5cf337082a82bf7bbb0aada7e97f47d14963bd6b0(page:)
    element_handle = page.query_selector("input")
    element_handle.type("some text")
    element_handle.press("Enter")
  end

  # FileChooser
  def example_371975841dd417527a865b1501e3a8ba40f905b895cf3317ca90d9890e980843(page:)
    file_chooser = page.expect_file_chooser do
      page.click("upload") # action to trigger file uploading
    end
    file_chooser.set_files("myfile.pdf")
  end

  # JSHandle
  def example_c408a96b8ac9c9bd54d915009c8b477eb75b7bf9e879fd76b32f3d4b6340a667(page:)
    window_handle = page.evaluate_handle("window")
    # ...
  end

  # JSHandle#evaluate
  def example_2400f96eaaed3bc6ef6b0a16ba48e83d38a166c7d55a5dba0025472cffc6f2be(page:)
    tweet_handle = page.query_selector(".tweet .retweets")
    tweet_handle.evaluate("node => node.innerText") # => "10 retweets"
  end

  # JSHandle#properties
  def example_8292f0e8974d97d20be9bb303d55ccd2d50e42f954e0ada4958ddbef2c6c2977(page:)
    page.goto('https://example.com/')
    window_handle = page.evaluate_handle("window")
    properties = window_handle.properties
    puts properties
    window_handle.dispose
  end

  # Playwright
  def example_efc99085566bf177ec87b1bd3bb30d75b6053ec9b579a8ac8bb9f22e5942289a
    require 'playwright'

    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      chromium = playwright.chromium # or "firefox" or "webkit".
      chromium.launch do |browser|
        page = browser.new_page
        page.goto('https://example.com/')

        # other actions

      end
    end
  end

  # Playwright#devices
  def example_2c0457a5b76f4a0471fcafd994f7bad94d04f6871480be8118d200c76e59dd72
    require 'playwright'

    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      iphone = playwright.devices["iPhone 6"]
      playwright.webkit.launch do |browser|
        context = browser.new_context(**iphone)
        page = context.new_page
        page.goto('https://example.com/')

        # other actions

      end
    end
  end

  # Page
  def example_d3546d9e2ff0cfa4b0f89f4f357816699c86075dc0dc48e65634d8f0521b5cf6(playwright:)
    playwright.webkit.launch do |browser|
      page = browser.new_page
      page.goto('https://example.com/')
      page.screenshot(path: 'screenshot.png')
    end
  end

  # Page - on
  def example_7c555f32653d321e7da3ac5dbb3a9bdf48a3ee9f7bad6e34765742ba1ab99484(page:)
    page.once("load", -> (page) { puts "page loaded!" })
  end

  # Page - on/off
  def example_dc5a169a728f9186d97bbbda448c9a41c908018224ed1df4545cab1ae979ec01(page:)
    listener = -> (req) { puts "a request was made: #{req.url}" }
    page.on('request', listener)
    page.goto('https://example.com/') # => prints 'a request was made: https://example.com/'
    page.off('request', listener)
    page.goto('https://example.com/') # => no print
  end

  # Page#add_init_script
  def example_7d496db52fdb297d5d1941f3a843bcb1b4deb6edd67b5160a880258ed22f2053(page:)
    # in your playwright script, assuming the preload.js file is in same directory
    page.add_init_script(path: "./preload.js")
  end

  # Page#dispatch_event
  def example_9220b94fd2fa381ab91448dcb551e2eb9806ad331c83454a710f4d8a280990e8(page:)
    page.content = '<button id="submit">Send</button>'
    page.dispatch_event("button#submit", "click")
  end

  # Page#dispatch_event
  def example_9b4482b7243b7ce304d6ce8454395e23db30f3d1d83229242ab7bd2abd5b72e0(page:)
    page.content = '<div id="source">Drag</div>'

    # note you can only create data_transfer in chromium and firefox
    data_transfer = page.evaluate_handle("new DataTransfer()")
    page.dispatch_event("#source", "dragstart", eventInit: { dataTransfer: data_transfer })
  end

  # Page#emulate_media
  def example_df304caf6c61f6f44b3e2b0006a7e05552362a47b17c9ba227df76e918d88a5c(page:)
    page.evaluate("matchMedia('screen').matches") # => true
    page.evaluate("matchMedia('print').matches") # => false

    page.emulate_media(media: "print")
    page.evaluate("matchMedia('screen').matches") # => false
    page.evaluate("matchMedia('print').matches") # => true

    page.emulate_media
    page.evaluate("matchMedia('screen').matches") # => true
    page.evaluate("matchMedia('print').matches") # => false
  end

  # Page#emulate_media
  def example_f0479a2ee8d8f51dab94f48b7e121cade07e5026d4f602521cc6ccc47feb5a98(page:)
    page.emulate_media(colorScheme="dark")
    page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches") # => true
    page.evaluate("matchMedia('(prefers-color-scheme: light)').matches") # => false
    page.evaluate("matchMedia('(prefers-color-scheme: no-preference)').matches") # => false
  end

  # Page#eval_on_selector
  def example_b3c0c695bba9bafb039d1003e5553b6792256703559205e4786e42a2b6800622(page:)
    search_value = page.eval_on_selector("#search", "el => el.value")
    preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
    html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", arg: "hello")
  end

  # Page#eval_on_selector_all
  def example_aff87cecea5eee1970fcc9d8baafbbfba24b300f9648c49033eed4b72e7b1dbd(page:)
    div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", arg: 10)
  end

  # Page#evaluate
  def example_7a5617310ae3ed83b6ca98b9f363441234fd7c25af7c86f81fe840d4599e4da8(page:)
    result = page.evaluate("([x, y]) => Promise.resolve(x * y)", arg: [7, 8])
    puts result # => "56"
  end

  # Page#evaluate
  def example_23b23ab6bd2ef249ab5ba8ecf6bdb1b450ce4a8a9685d23b0b050cf1b040b7da(page:)
    puts page.evaluate("1 + 2") # => 3
    x = 10
    puts page.evaluate("1 + #{x}") # => "11"
  end

  # Page#evaluate
  def example_54a27f89dda0a0a05fac76ffad76c4a1173dae259842d15dbaf7ea587e6e327d(page:)
    body_handle = page.query_selector("body")
    html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
    body_handle.dispose
  end

  # Page#evaluate_handle
  def example_6802829f93cc4da7e67f3886b9773c7b84054afa84251add50704f8ca6837138(page:)
    a_window_handle = page.evaluate_handle("Promise.resolve(window)")
    a_window_handle # handle for the window object.
  end

  # Page#evaluate_handle
  def example_9daa37cfd3d747c9360d9544f64786bf49d291a6887b0efccc813215b62ae4c6(page:)
    a_handle = page.evaluate_handle("document") # handle for the "document"
  end

  # Page#evaluate_handle
  def example_fd8ed14043be0b21635ea7b0c55b59c55991a6a686904fcb82f2eee7671f9d55(page:)
    body_handle = page.evaluate_handle("document.body")
    result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
    puts result_handle.json_value
    result_handle.dispose
  end

  # Page#expose_binding
  def example_551f5963351bfd7141fa8c94f5f22c305ec1c01d617861953374e9290929a551(page:)
    page.expose_binding("pageURL", ->(source) { source[:page].url })
    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.pageURL();
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML
    page.click("button")
  end

  # Page#expose_binding
  def example_6534a792e99e05b5644cea6e5b77ca5d864675a3012f447f0f8318c4fa6a6a54(page:)
    def print_text(source, element)
      element.text_content
    end

    page.expose_binding("clicked", method(:print_text), handle: true)
    page.content = <<~HTML
    <script>
      document.addEventListener('click', async (event) => {
        alert(await window.clicked(event.target));
      })
    </script>
    <div>Click me</div>
    <div>Or click me</div>
    HTML

    page.click('div')
  end

  # Page#expose_function
  def example_3692cd13d12f1d501e2a5e8e6a60d335c5ad54ab3b5eb34e3cec0227106d89f0(page:)
    require 'digest'

    def sha1(text)
      Digest::SHA256.hexdigest(text)
    end

    page.expose_function("sha256", method(:sha256))
    page.content = <<~HTML
    <script>
      async function onClick() {
        document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
      }
    </script>
    <button onclick="onClick()">Click me</button>
    <div></div>
    HTML
    page.click("button")
  end

  # Page#frame
  def example_034f224ec0f7b4d98fdf875cefbc7e6c8726a6d615cbba9b1cb8c49180fd7d69(page:)
    frame = page.frame(name: "frame-name")
  end

  # Page#frame
  def example_a8a4717d8505a35662faafa9e6c2cfbbc0a44755c8e4d43252f882b7e4f1f04a(page:)
    frame = page.frame(url: /.*domain.*/)
  end

  # Page#pdf
  def example_e079fbec8ee0607ee45cdca94df61dea36f7fd3840986d5f4ac24918569a5f5e(page:)
    # generates a pdf with "screen" media type.
    page.emulate_media(media: "screen")
    page.pdf(path: "page.pdf")
  end

  # Page#press
  def example_aa4598bd7dbeb8d2f8f5c0aa3bdc84042eb396de37b49f8ff8c1ea39f080f709(page:)
    page.goto("https://keycode.info")
    page.press("body", "A")
    page.screenshot(path: "a.png")
    page.press("body", "ArrowLeft")
    page.screenshot(path: "arrow_left.png")
    page.press("body", "Shift+O")
    page.screenshot(path: "o.png")
  end

  # Page#route
  def example_a3038a6fd55b06cb841251877bf6eb781b08018695514c6e0054848d4e93d345(page:)
    page.route("**/*.{png,jpg,jpeg}", ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # Page#route
  def example_7fda2a761bdd66b942415ab444c6b4bb89dd87ec0f0a4a03e6775feb694f7913(page:)
    page.route(/\.(png|jpg)$/, ->(route, request) { route.abort })
    page.goto("https://example.com")
  end

  # Page#route
  def example_ff4fba1273c7e65f4d68b4fcdd9dc4b792bba435005f0b9e7066ca18ded750b5(pgae:)
    def handle_route(route, request)
      if request.post_data["my-string"]
        mocked_data = request.post_data.merge({ "my-string" => 'mocked-data'})
        route.fulfill(postData: mocked_data)
      else
        route.continue
      end
    end
    page.route("/api/**", method(:handle_route))
  end

  # Page#select_option
  def example_4b17eb65721c55859c50eb12b4ee762e65408618cf3b7d07958b68d60ea6be6c(page:)
    # single selection matching the value
    page.select_option("select#colors", value: "blue")
    # single selection matching both the label
    page.select_option("select#colors", label: "blue")
    # multiple selection
    page.select_option("select#colors", value: ["red", "green", "blue"])
  end

  # Page#set_viewport_size
  def example_e3883d51c0785c34b62633fe311c4f1252dd9f29e6b4b6c7719f1eb74384e6e9(page:)
    page.viewport_size = { width: 640, height: 480 }
    page.goto("https://example.com")
  end

  # Page#type
  def example_4c7291f6023d2fe4f957cb7727646b50fdee40275db330a6f4517e349ea7f916(page:)
    page.type("#mytextarea", "hello") # types instantly
    page.type("#mytextarea", "world", delay: 100) # types slower, like a user
  end

  # Page#expect_event
  def example_1b007e0db5f2b594b586367be3b56f9eb9b928740efbceada2c60cb7794592d4(page:)
    frame = page.expect_event("framenavigated") do
      page.click("button")
    end
  end

  # Page#wait_for_function
  def example_e50869c913bec2f0a89a22ff1c438128c3c8f2e3710acb10665445cf52e3ec73(page:)
    page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    page.wait_for_function("() => window.x > 0")
  end

  # Page#wait_for_function
  def example_04c93558dde8de62944515a8ed91fda6e0d01feca4d3bb2e58c6fda10a8c6ade(page:)
    selector = ".foo"
    page.wait_for_function("selector => !!document.querySelector(selector)", arg: selector)
  end

  # Page#wait_for_load_state
  def example_cd35fb085612055231ddf97f68bc5331b4620914e0686b889f2cd4061836cff8(page:)
    page.click("button") # click triggers navigation.
    page.wait_for_load_state # the promise resolves after "load" event.
  end

  # Page#wait_for_load_state
  def example_51ba8a745d5093516e9a50482d8bf3ce29afe507ca5cfe89f4a0e35963f52a36(page:)
    popup = page.expect_popup do
      page.click("button") # click triggers a popup.
    end

    # Following resolves after "domcontentloaded" event.
    popup.wait_for_load_state("domcontentloaded")
    puts popup.title # popup is ready to use.
  end

  # Page#expect_navigation
  def example_bc5a01f756c1275b9942c4b3e50a9f1748c04da8d5f8f697567b9d04806ec0dc(page:)
    page.expect_navigation do
      page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    end # Resolves after navigation has finished
  end

  # Page#expect_request
  def example_9246912bc386c2f9310662279b12200ae131f724a1ec1ca99e511568767cb9c8(page:)
    page.content = '<form action="https://example.com/resource"><input type="submit" /></form>'
    request = page.expect_request(/example.com\/resource/) do
      page.click("input")
    end
    puts request.headers

    page.wait_for_load_state # wait for request finished.

    # or with a predicate
    page.content = '<form action="https://example.com/resource"><input type="submit" /></form>'
    request = page.expect_request(->(req) { req.url.start_with? 'https://example.com/resource' }) do
      page.click("input")
    end
    puts request.headers
  end

  # Page#expect_response
  def example_d2a76790c0bb59bf5ae2f41d1a29b50954412136de3699ec79dc33cdfd56004b(page:)
    page.content = '<form action="https://example.com/resource"><input type="submit" /></form>'
    response = page.expect_response(/example.com\/resource/) do
      page.click("input")
    end
    puts response.body

    # or with a predicate
    page.content = '<form action="https://example.com/resource"><input type="submit" /></form>'
    response = page.expect_response(->(res) { res.url.start_with? 'https://example.com/resource' }) do
      page.click("input")
    end
    puts response.body
  end

  # Page#wait_for_selector
  def example_0a62ff34b0d31a64dd1597b9dff456e4139b36207d26efdec7109e278dc315a3(page:)
    %w[https://google.com https://bbc.com].each do |current_url|
      page.goto(current_url, waitUntil: "domcontentloaded")
      element = page.wait_for_selector("img")
      puts "Loaded image: #{element["src"]}"
    end
  end

  # Page#wait_for_url
  def example_a49b1deed2b93fe358b57bca9c4032f44b3d24436a78720421ba040aad4d661c(page:)
    page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    page.wait_for_url("**/target.html")
  end

  # Route#continue
  def example_1960aabd58c9553683368e29429d39c1209d35e6e3625bbef1280a1fa022a9ee(page:)
    def handle(route, request)
      # override headers
      headers = request.headers
      headers['foo'] = 'bar' # set "foo" header
      headers['user-agent'] = 'Unknown Browser' # modify user-agent

      route.continue(headers: headers)
    end
    page.route("**/*", method(:handle))
  end

  # Route#fulfill
  def example_6d2dfd4bb5c8360f8d80bb91c563b0bd9b99aa24595063cf85e5a6e1b105f89c(page:)
    page.route("**/*", ->(route, request) {
      route.fulfill(
        status: 404,
        contentType: 'text/plain',
        body: 'not found!!',
      )
    })
  end

  # Route#fulfill
  def example_c77fd0986d0b74c905cd9417756c76775e612cc86410f9a5aabc5b46d233d150(page:)
    page.route("**/xhr_endpoint", ->(route, _) { route.fulfill(path: "mock_data.json") })
  end
end
