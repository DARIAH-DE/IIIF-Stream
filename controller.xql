xquery version "3.1";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;

declare variable $sid := "ADD YOUR SID HERE";
declare variable $this-url := "https://ci.de.dariah.eu/tg-iiif";
declare variable $path := tokenize($exist:path, "/")[.!=""];

declare variable $response-header := response:set-header("access-control-allow-origin", "*");

try {
switch ($path[1])
    case "image" return
            let $url := "https://textgridlab.org/1.0/digilib/rest/IIIF/"||$path[2]||";sid="|| $sid ||"/"||string-join($path[position() gt 2], "/")
            let $request := httpclient:get($url, false(), ())
            let $binary-data := $request/httpclient:body/text()
            let $mime := string($request/httpclient:body/@mimetype)
            return
                if($exist:resource = "info.json") then
                    util:base64-decode($binary-data)
                    => replace("https://textgridlab.org/1.0/digilib/rest/IIIF/", $this-url || "/image/")
                    => util:base64-encode()
                    => response:stream-binary($mime)
                else
                    response:stream-binary($binary-data, $mime)

    case "manifests" return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/manifest.xql">
                <add-parameter name="sid" value="{$sid}"/>
                <add-parameter name="resource" value="{$path[2]}"/>
                <add-parameter name="this-url" value="{$this-url}"/>
            </forward>
        </dispatch>

    default return <error>You sent something unexpected.</error>
} catch * {
    <error>an error occured.</error>
}
