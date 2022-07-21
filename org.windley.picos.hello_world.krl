ruleset org.windley.picos.hello_world {
  meta {
    name "hello"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares hello
  }
  global {
    event_domain = "org_windley_picos_hello_world"
    hello = function(_headers){
      html:header("manage hello","",null,null,_headers)
      + <<
<h1>Manage hello</h1>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["hello"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise org_windley_picos_hello_world event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when org_windley_picos_hello_world factory_reset
    foreach wrangler:channels(["hello"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}
