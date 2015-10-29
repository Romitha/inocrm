window.Admins =
  setup: ->
    @admin_menu_dropdown()
    return

  admin_menu_dropdown: ->
    $(".with_submenu a.pull-right").click ->
      $("span",this).toggleClass("icon-chevron-left icon-chevron-down");


    # OPTIMIZE <div id='translControl'></div>
    # <br>Title : <input type='textbox' id="transl1"/>
    # <br>Body<br><textarea id="transl2" style="width:600px;height:200px"></textarea>
    # %footer.navbar-inverse
    #   = render "layouts/footer"

    # <script type="text/javascript" src="http://www.google.com/jsapi">

    # </script>

    # <script type="text/javascript">
    # // Load the Google Transliterate API
    # google.load("elements", "1", {
    # packages: "transliteration"
    # });

    # function onLoad() {
    # var options = {
    # sourceLanguage: 'en',
    # destinationLanguage: ['hi','kn','ml','ta','te'],
    # shortcutKey: 'ctrl+g',
    # transliterationEnabled: true
    # };

    # // Create an instance on TransliterationControl with the required
    # // options.
    # var control =
    # new google.elements.transliteration.TransliterationControl(options);

    # // Enable transliteration in the textfields with the given ids.
    # var ids = [ "transl1", "transl2" ];
    # control.makeTransliteratable(ids);

    # // Show the transliteration control which can be used to toggle between
    # // English and Hindi and also choose other destination language.
    # control.showControl('translControl');
    # }
    # google.setOnLoadCallback(onLoad);
    # </script>