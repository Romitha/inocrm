App = Ember.Application.create
  rootElement: "#ember-app"

App.Router = Ember.Router.extend
  rootURL: "/tickets/assign-ticket/"

App.Router.map ->
  @route "groups", {path: "/groups/:ticket_id"}
  return

# ******** Index *************
App.ApplicationRoute = Ember.Route.extend
  showGroupFormBool: false

  model: ->
    Ember.$.getJSON('/tickets/load_sbu', {type: "sbu"}).then( (data)-> data.sbus )

App.ApplicationController = Ember.Controller.extend

  assignToObserver: Ember.observer "newObj.sbu_id", ->

    if Ember.isPresent(@get("newObj.sbu_id"))
      Ember.$.getJSON("/tickets/load_sbu", {type: "sbu", filter_sbu: @get("newObj.sbu_id")}).then (data)=>
        @set("assignTo", data.sbus)
        @set "newObj.assign_to", null
        @set "newObj.subEng", []

  actions:
    showGroupForm: ->
      @toggleProperty "showGroupFormBool"

      if @get("showGroupFormBool")
        obj = App.Engineer.create()

        @set "newObj", obj

      return

    saveNewObj: ->
      Ember.$.post("/tickets/update_assign_engineer_ticket", {assign_eng_params: JSON.stringify(@get("newObj")) }).then (response)=>
        console.log response
# ******** Index *************

App.Engineer = Ember.Object.extend()
App.SubEngineer = Ember.Object.extend()

App.GroupsRoute = Ember.Route.extend
  model: (params)-> Ember.$.getJSON('/tickets/load_sbu', {type: "ticket", ticket_id: params.ticket_id}).then( (data)-> data.ticketEngs )

  actions:
    removeTicketEng: (obj)->
      console.log obj

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

    saveEng: ->
      console.log "submitted"
      return

App.GroupListComponent = Ember.Component.extend
  imageNotAvailable: Ember.computed.equal("ticketEng.image", null)

App.SelectBoxComponent = Ember.Component.extend
  tagName: "select"
  classNames: ["form-control"]

  actions:
    selectedValue: (value)->
      console.log "clicked"