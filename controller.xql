xquery version "3.1";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;

declare variable $config := doc("config.xml")/config;
declare variable $sid := $config/sid/string();
declare variable $iiif := $config/textgrid/iiif/string();
declare variable $this-url := $config/url/string();
declare variable $path := tokenize($exist:path, "/")[.!=""];

declare variable $response-header := response:set-header("access-control-allow-origin", "*");

try {
switch ($path[1])
    case "image" return
            let $url := $iiif||$path[2]||";sid="|| $sid ||"/"||string-join($path[position() gt 2], "/")
            let $request := httpclient:get($url, false(), ())
            let $data := $request/httpclient:body/text()
            let $binary-data := try { $data => xs:base64Binary() }
                                catch * {
                                    error(QName("err", "load1"), string-join(("&#10;Could not load data from TextGrid: ",$data,$err:code,$err:description), "&#10;"))
                                }
                
            let $mime := string($request/httpclient:body/@mimetype)
            return
                if($exist:resource = "info.json")
                then
                    util:base64-decode($binary-data)
                    => replace($iiif, $this-url  || "/image/")
                    => util:base64-encode()
                    => response:stream-binary($mime)
                else
                    response:stream-binary($binary-data, $mime)
    
    case "manifests" return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$exist:controller}/manifest.xql">
                <add-parameter name="resource" value="{$path[2]}"/>
            </forward>
        </dispatch>
            
    default return <error>You sent something unexpected.</error>
} catch * {
    <error>an error occured.</error>
}