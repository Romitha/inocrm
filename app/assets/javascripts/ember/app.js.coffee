App = Ember.Application.create
  rootElement: "#ember-app"

App.Router = Ember.Router.extend
  rootURL: "/tickets/assign-ticket/"

App.Router.map ->
  @route "groups"
  return

# ******** Index *************
App.IndexRoute = Ember.Route.extend
  showGroupFormBool: false

  model: ->
    ['red', 'yellow', 'blue']

App.IndexController = Ember.Controller.extend
  actions:
    showGroupForm: ->
      obj = App.Engineer.create()

      @set "newObj", obj

      @set "selectArray", [{id: 1, name: "a"}, {id: 2, name: "b"}, {id: 3, name: "c"},]

      @toggleProperty "showGroupFormBool"
      return

# ******** Index *************


App.GroupsRoute = Ember.Route.extend()
App.Engineer = Ember.Object.extend()
App.SubEngineer = Ember.Object.extend()

App.NewGroupComponent = Ember.Component.extend
  init: ->
    @_super()
    @set "obj.ticket_id", @get("ticketId")

  actions:
    addSubEng: ->
      parentObj = @get("obj")
      newSubEng = App.SubEngineer.create()

      if Ember.isPresent(parentObj.subEng)
        parentObj.subEng.addObject(newSubEng)

      else
        parentObj.set "subEng", [].addObject(newSubEng)

    removeSubEng: (remObj)->
      @get("obj.subEng").removeObject(remObj)

App.SelectBoxComponent = Ember.Component.extend
  tagName: "select"
  classNames: ["form-control"]

  actions:
    selectedValue: (value)->
      console.log "clicked"