utils = require "./jasmine-utils"

prepare_builder = ->
  SequenceDiagramBuilder = require "SequenceDiagramBuilder"
  @builder = new SequenceDiagramBuilder
  @diagram = @builder.diagram()
  utils.matchers this

describe "SequenceDiagramBuilder", ->

  beforeEach prepare_builder

  describe "diagram", ->

    it "returns diagram", ->
      expect(@builder.diagram()).haveClass "diagram"
  
  describe "found", ->

    it "gives an object having .found", ->
      @builder.found "biz"
      obj = @diagram.find ".object"
      expect(obj.length).toBe 1
      expect(obj).haveClass "found"
      expect(obj.find(".name").text()).toBe "biz"
    
  describe "message", ->

    beforeEach ->
      @builder.found("foo")
              .message "call", "bar"
  
    it "returns itself", ->
      expect(@builder.found("foo").message "call").toBeDefined()
    
    it "gives an interaction and an occurrence", ->
      iact = @diagram.find "> .interaction"
      expect(iact.length).toBe 1
      expect(iact.find("> .occurrence").length).toBe 1
      expect(iact.find("> .occurrence > .interaction").length).toBe 1
      expect(iact.find("> .occurrence > .interaction > .message").length).toBe 1

    describe "nesting", ->

      beforeEach prepare_builder

      it "returns back to previous occurrence", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "1-1", "b-1", ->
            @message "2", "c", ->
              @message "2-1", "c-1", ->
          """
        
        expect((diag.find "> .interaction").length).toBe 1
        expect((iacts = diag.find """
          > .interaction
            > .occurrence
              > .interaction
          """).length).toBe 2  ## including msg 1 and 2

        occur0 = iacts.filter(":eq(0)").find "> .occurrence"
        occur1 = iacts.filter(":eq(1)").find "> .occurrence"
        expect(occur0.find("> .interaction > .message").text()).toBe "1-1"
        expect(occur1.find("> .interaction > .message").text()).toBe "2-1"
        #utils.glance diag

    describe "twice", ->

      beforeEach prepare_builder

      it "makes two parallel interactions", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b"
            @message "2", "c"
          """
        sel = "> .interaction:eq(0) > .occurrence:eq(0)"
        expect("1").toBe diag.find("#{sel} > .interaction:eq(0) > .message .name").text()
        expect("2").toBe diag.find("#{sel} > .interaction:eq(1) > .message .name").text()

      it "makes two nested interations", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "2", "c"
          """
        expect("2").toBe diag.find("
          > .interaction:eq(0)
            > .occurrence:eq(0)
              > .interaction:eq(0)
                > .occurrence:eq(0)
                  > .interaction:eq(0)
                    > .message .name
          ").text()

  describe "create", ->

  describe "destroy", ->

  describe "reply", ->

  describe "ref", ->

    it "returns itself", ->
      a = @builder.ref "i'm ref"
      expect(a).toBe @builder

  describe "loop", ->

  describe "alt", ->

    beforeEach ->
      @diagram = @builder.build """
        @found "open", ->
          @alt {
            "[found]": -> @message "write", "File"
            "[missing]": -> @message "close", "File"
          }
        """
      @alt = @diagram.find(".alt").data "_self"

    it "has .alt", ->
      expect(@alt.length).toBe 1

    it "has empty .name", ->
      expect(@alt.find(".name:eq(0)").text()).toBe 'alt'

  describe "reactivate", ->

  describe "lost", ->
  
  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node).haveClass "diagram"

    describe "found", ->

      it "gives an interaction and an occurrence", ->
        @builder.build """@found 'sth'"""
        iact = @diagram.find ".interaction:eq(0)"
        expect(iact.length).toBe 1
        expect(iact.find("> .occurrence").length).toBe 1

