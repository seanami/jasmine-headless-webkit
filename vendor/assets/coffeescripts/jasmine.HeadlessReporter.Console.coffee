#= require jasmine.HeadlessReporter.js
#
class jasmine.HeadlessReporter.Console extends jasmine.HeadlessReporter
  constructor: (@callback = null) ->
    super(@callback)

    @position = 0
    @positions = "|/-\\"

  reportRunnerResults: (runner) ->
    super()

    this.print("\n")

    resultLine = this.formatResultLine(this._runtime())

    if @failedCount == 0
      this.puts("PASS: #{resultLine}".foreground('green'))
    else
      this.puts("FAIL: #{resultLine}".foreground('red'))

    for result in @results
      this.puts(result.toString())

    this.puts("\nTest ordering seed: --seed #{JHW.getSeed()}")

  reportRunnerStarting: (runner) ->
    super(runner)
    this.puts("\nRunning Jasmine specs...".bright()) if !this.hasError()

  reportSpecResults: (spec) ->
    super(spec)

    this._reportSpecResult(spec, {
      success: (results) =>
        this.print('.'.foreground('green'))
      failure: (results) =>
        this.print('F'.foreground('red'))

        failureResult = new HeadlessReporterResult(spec.getFullName(), spec.getSpecSplitName())
        testCount = 1

        for result in results.getItems()
          if result.type == 'expect' and !result.passed_
            if foundLine = result.expectations[testCount - 1]
              [ result.line, result.lineNumber ] = foundLine
            failureResult.addResult(result)
          testCount += 1
        @results.push(failureResult)
    })

  reportSpecWaiting: ->
    if !@timer
      @timer = true
      @first = true

      this._waitRunner()

  reportSpecRunning: ->
    if @timer
      clearTimeout(@timer)
      @timer = null
      this.print(Intense.moveBack())

  formatResultLine: (runtime) ->
    line = []
    line.push(@length)
    line.push((if @length == 1 then "test" else "tests") + ',')

    line.push(@failedCount)
    line.push((if @failedCount == 1 then "failure" else "failures") + ',')

    line.push(runtime)
    line.push((if runtime == 1.0 then "sec" else "secs") + '.')

    line.join(' ')

  _waitRunner: =>
    @timer = setTimeout(
      =>
        if @timer
          this.print(Intense.moveBack()) if !@first
          this.print(@positions.substr(@position, 1).foreground('yellow'))
          @position += 1
          @position %= @positions.length
          @first = false
          this._waitRunner()
      , 750
    )
