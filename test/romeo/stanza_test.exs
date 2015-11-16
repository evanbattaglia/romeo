defmodule Romeo.StanzaTest do
  use ExUnit.Case, async: true
  use Romeo.XML

  alias Romeo.Stanza

  doctest Romeo.Stanza

  test "start_stream with default xmlns" do
    assert Stanza.start_stream("im.wonderland.lit") |> Stanza.to_xml ==
      "<stream:stream to='im.wonderland.lit' version='1.0' xml:lang='en' xmlns='jabber:client' xmlns:stream='#{ns_xmpp}'>"
  end

  test "start_stream with 'jabber:server' xmlns" do
    assert Stanza.start_stream("im.wonderland.lit", ns_jabber_server) |> Stanza.to_xml ==
      "<stream:stream to='im.wonderland.lit' version='1.0' xml:lang='en' xmlns='jabber:server' xmlns:stream='http://etherx.jabber.org/streams'>"
  end

  test "end_stream" do
    assert Stanza.end_stream |> Stanza.to_xml == "</stream:stream>"
  end

  test "start_tls" do
    assert Stanza.start_tls |> Stanza.to_xml ==
      "<starttls xmlns='#{ns_tls}'/>"
  end

  test "get_inband_register" do
    assert Stanza.get_inband_register |> Stanza.to_xml =~
      ~r"<iq type='get' id='(.*)'><query xmlns='jabber:iq:register'/></iq>"
  end

  test "set_inband_register" do
    assert Stanza.set_inband_register("username", "password") |> Stanza.to_xml =~
      ~r"<iq type='set' id='(.*)'><query xmlns='jabber:iq:register'><username>username</username><password>password</password></query></iq>"
  end

  test "subscribe" do
    assert Stanza.subscribe("pubsub.wonderland.lit", "posts", "alice@wonderland.lit") |> Stanza.to_xml =~
      ~r"<iq to='pubsub.wonderland.lit' type='set' id='(.*)'><pubsub xmlns='http://jabber.org/protocol/pubsub'><subscribe node='posts' jid='alice@wonderland.lit'/></pubsub></iq>"
  end

  test "compress" do
    assert Stanza.compress("zlib") |> Stanza.to_xml ==
      "<compress xmlns='#{ns_compress}'><method>zlib</method></compress>"
  end

  test "auth" do
    data = <<0>> <> "username" <> <<0>> <> "password"
    assert Stanza.auth("PLAIN", Stanza.base64_cdata(data)) |> Stanza.to_xml ==
      "<auth xmlns='#{ns_sasl}' mechanism='PLAIN'>AHVzZXJuYW1lAHBhc3N3b3Jk</auth>"
  end

  test "bind" do
    assert Stanza.bind("hedwig") |> Stanza.to_xml =~
      ~r"<iq type='set' id='(.*)'><bind xmlns='#{ns_bind}'><resource>hedwig</resource></bind></iq>"
  end

  test "session" do
    assert Stanza.session |> Stanza.to_xml =~
      ~r"<iq type='set' id='(.*)'><session xmlns='#{ns_session}'/></iq>"
  end

  test "presence" do
    assert Stanza.presence |> Stanza.to_xml == "<presence/>"
  end

  test "presence/2" do
    assert Stanza.presence("room@muc.localhost/nick", "unavailable") |> Stanza.to_xml ==
      "<presence type='unavailable' to='room@muc.localhost/nick'/>"
  end

  test "message" do
    assert Stanza.message("test@localhost", "chat", "Hello") |> Stanza.to_xml =~
      ~r"<message to='test@localhost' type='chat' id='(.*)' xml:lang='en'><body>Hello</body></message>"
  end
end
