xquery version "3.1";

declare namespace exif="http://www.w3.org/2003/12/exif/ns#";
declare namespace ore="http://www.openarchives.org/ore/terms/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tgmd="http://textgrid.info/namespaces/metadata/core/2010";
declare namespace tgs="http://www.textgrid.info/namespaces/middleware/tgsearch";

declare option output:method "json";
declare option output:media-type "application/json";

let $resource := request:get-parameter("resource", "textgrid:3q4gd.0")
let $sid := request:get-parameter("sid", "")
let $this-url := request:get-parameter("this-url", "")
let $this-url-manifests := $this-url || "/manifests/" || $resource

let $url := "https://textgridlab.org/1.0/tgcrud/rest/"||$resource||"/metadata?sessionId="|| $sid
let $agg-metadata := httpclient:get(xs:anyURI($url), false(), ())
let $all-metadata := httpclient:get(xs:anyURI("https://textgridlab.org/1.0/tgsearch/navigation/agg/"||$resource || "?sid=" || $sid), false(), ())

let $images := 	for $result in $all-metadata//tgs:result
				where starts-with($result//tgmd:format, "image/")
				where $result//exif:height
				where $result//exif:width
				return
					map{
						"@id":  $this-url-manifests || "/canvas/" || string($result/@textgridUri) || ".json",
						"@type": "sc:Canvas",
						"label": string($result//tgmd:title),
						"height": number($result//exif:height),
						"width": number($result//exif:width),
						"images": [
							map {
								"@id": $this-url-manifests ||"/annotation/" || string($result/@textgridUri) || ".json",
								"@type": "oa:Annotation",
								"resource": map {
									"@id": "http://textgridlab.org/1.0/tgcrud/rest/" || string($result/@textgridUri) || "/data",
									"@type": "dctypes:Image",
									"format": string($result//tgmd:format),
									"service": map {
										"@id": substring-before($this-url-manifests, "manifests/") || "image/" ||string($result/@textgridUri),
										"profile": "http://iiif.io/api/image/2/level2.json",
										"@context": "http://iiif.io/api/image/2/context.json"
										},
									"height": number($result//exif:height),
									"width": number($result//exif:width)
									},
								"on": $this-url-manifests || "/canvas/" || string($result/@textgridUri) || ".json",
								"motivation": "sc:painting"
								} ]
					}

let $json :=
    map{
        "within": "https://textgridrep.org/",
        "logo": "https://textgridrep.org/textgrid-theme/images/textgrid-repository-logo.svg",
        "@context": "http://iiif.io/api/presentation/2/context.json",
        "label": string($agg-metadata//tgmd:project) || ": " || string($agg-metadata//tgmd:title),
        "@type": "sc:Manifest",
        "@id":  $this-url-manifests ||"/manifest.json",
        "description": "not available",
        "attribution": "rightsholder: not present for test data",
        "sequences": [
        	map {
				"@id": $this-url-manifests || "/sequence/normal.json",
				"@type": "sc:Sequence",
				"label": "Current Page Order",
				"viewingDirection": "left-to-right",
				"viewingHint": "paged",
				"canvases":
					$images
			}
		]
    }

return
	$json
