
�y
google/api/http.proto
google.api"y
Http*
rules (2.google.api.HttpRuleRrulesE
fully_decode_reserved_expansion (RfullyDecodeReservedExpansion"�
HttpRule
selector (	Rselector
get (	H Rget
put (	H Rput
post (	H Rpost
delete (	H Rdelete
patch (	H Rpatch7
custom (2.google.api.CustomHttpPatternH Rcustom
body (	Rbody#
response_body (	RresponseBodyE
additional_bindings (2.google.api.HttpRuleRadditionalBindingsB	
pattern";
CustomHttpPattern
kind (	Rkind
path (	RpathBj
com.google.apiB	HttpProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations��GAPIJ�t
 �
�
 2� Copyright 2018 Google LLC.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.





 
	
 

 X
	
 X

 "
	

 "

 *
	
 *

 '
	
 '

 "
	
$ "
�
  +� Defines the HTTP configuration for an API service. It contains a list of
 [HttpRule][google.api.HttpRule], each specifying the mapping of an RPC method
 to one or more HTTP REST API methods.



 
�
  "� A list of HTTP configuration rules that apply to individual API methods.

 **NOTE:** All service configuration rules follow "last one wins" order.


  "


  "

  "

  "
�
 *+� When set to true, URL path parmeters will be fully URI-decoded except in
 cases of single segment matches in reserved expansion, where "%2F" will be
 left encoded.

 The default behavior is to not decode RFC 6570 reserved characters in multi
 segment matches.


 *"

 *

 *&

 *)*
�S
� ��S # gRPC Transcoding

 gRPC Transcoding is a feature for mapping between a gRPC method and one or
 more HTTP REST endpoints. It allows developers to build a single API service
 that supports both gRPC APIs and REST APIs. Many systems, including [Google
 APIs](https://github.com/googleapis/googleapis),
 [Cloud Endpoints](https://cloud.google.com/endpoints), [gRPC
 Gateway](https://github.com/grpc-ecosystem/grpc-gateway),
 and [Envoy](https://github.com/envoyproxy/envoy) proxy support this feature
 and use it for large scale production services.

 `HttpRule` defines the schema of the gRPC/REST mapping. The mapping specifies
 how different portions of the gRPC request message are mapped to the URL
 path, URL query parameters, and HTTP request body. It also controls how the
 gRPC response message is mapped to the HTTP response body. `HttpRule` is
 typically specified as an `google.api.http` annotation on the gRPC method.

 Each mapping specifies a URL path template and an HTTP method. The path
 template may refer to one or more fields in the gRPC request message, as long
 as each field is a non-repeated field with a primitive (non-message) type.
 The path template controls how fields of the request message are mapped to
 the URL path.

 Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get: "/v1/{name=messages/*}"
         };
       }
     }
     message GetMessageRequest {
       string name = 1; // Mapped to URL path.
     }
     message Message {
       string text = 1; // The resource content.
     }

 This enables an HTTP REST to gRPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456`  | `GetMessage(name: "messages/123456")`

 Any fields in the request message which are not bound by the path template
 automatically become HTTP query parameters if there is no HTTP request body.
 For example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
             get:"/v1/messages/{message_id}"
         };
       }
     }
     message GetMessageRequest {
       message SubMessage {
         string subfield = 1;
       }
       string message_id = 1; // Mapped to URL path.
       int64 revision = 2;    // Mapped to URL query parameter `revision`.
       SubMessage sub = 3;    // Mapped to URL query parameter `sub.subfield`.
     }

 This enables a HTTP JSON to RPC mapping as below:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456?revision=2&sub.subfield=foo` | `GetMessage(message_id: "123456" revision: 2 sub: SubMessage(subfield: "foo"))`

 Note that fields which are mapped to URL query parameters must have a
 primitive type or a repeated primitive type or a non-repeated message type.
 In the case of a repeated type, the parameter can be repeated in the URL
 as `...?param=A&param=B`. In the case of a message type, each field of the
 message is mapped to a separate parameter, such as
 `...?foo.a=A&foo.b=B&foo.c=C`.

 For HTTP methods that allow a request body, the `body` field
 specifies the mapping. Consider a REST update method on the
 message resource collection:

     service Messaging {
       rpc UpdateMessage(UpdateMessageRequest) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "message"
         };
       }
     }
     message UpdateMessageRequest {
       string message_id = 1; // mapped to the URL
       Message message = 2;   // mapped to the body
     }

 The following HTTP JSON to RPC mapping is enabled, where the
 representation of the JSON in the request body is determined by
 protos JSON encoding:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id: "123456" message { text: "Hi!" })`

 The special name `*` can be used in the body mapping to define that
 every field not bound by the path template should be mapped to the
 request body.  This enables the following alternative definition of
 the update method:

     service Messaging {
       rpc UpdateMessage(Message) returns (Message) {
         option (google.api.http) = {
           patch: "/v1/messages/{message_id}"
           body: "*"
         };
       }
     }
     message Message {
       string message_id = 1;
       string text = 2;
     }


 The following HTTP JSON to RPC mapping is enabled:

 HTTP | gRPC
 -----|-----
 `PATCH /v1/messages/123456 { "text": "Hi!" }` | `UpdateMessage(message_id: "123456" text: "Hi!")`

 Note that when using `*` in the body mapping, it is not possible to
 have HTTP parameters, as all fields not bound by the path end in
 the body. This makes this option more rarely used in practice when
 defining REST APIs. The common usage of `*` is in custom methods
 which don't use the URL at all for transferring data.

 It is possible to define multiple HTTP methods for one RPC by using
 the `additional_bindings` option. Example:

     service Messaging {
       rpc GetMessage(GetMessageRequest) returns (Message) {
         option (google.api.http) = {
           get: "/v1/messages/{message_id}"
           additional_bindings {
             get: "/v1/users/{user_id}/messages/{message_id}"
           }
         };
       }
     }
     message GetMessageRequest {
       string message_id = 1;
       string user_id = 2;
     }

 This enables the following two alternative HTTP JSON to RPC mappings:

 HTTP | gRPC
 -----|-----
 `GET /v1/messages/123456` | `GetMessage(message_id: "123456")`
 `GET /v1/users/me/messages/123456` | `GetMessage(user_id: "me" message_id: "123456")`

 ## Rules for HTTP mapping

 1. Leaf request fields (recursive expansion nested messages in the request
    message) are classified into three categories:
    - Fields referred by the path template. They are passed via the URL path.
    - Fields referred by the [HttpRule.body][google.api.HttpRule.body]. They are passed via the HTTP
      request body.
    - All other fields are passed via the URL query parameters, and the
      parameter name is the field path in the request message. A repeated
      field can be represented as multiple query parameters under the same
      name.
  2. If [HttpRule.body][google.api.HttpRule.body] is "*", there is no URL query parameter, all fields
     are passed via URL path and HTTP request body.
  3. If [HttpRule.body][google.api.HttpRule.body] is omitted, there is no HTTP request body, all
     fields are passed via URL path and URL query parameters.

 ### Path template syntax

     Template = "/" Segments [ Verb ] ;
     Segments = Segment { "/" Segment } ;
     Segment  = "*" | "**" | LITERAL | Variable ;
     Variable = "{" FieldPath [ "=" Segments ] "}" ;
     FieldPath = IDENT { "." IDENT } ;
     Verb     = ":" LITERAL ;

 The syntax `*` matches a single URL path segment. The syntax `**` matches
 zero or more URL path segments, which must be the last part of the URL path
 except the `Verb`.

 The syntax `Variable` matches part of the URL path as specified by its
 template. A variable template must not contain other variables. If a variable
 matches a single path segment, its template may be omitted, e.g. `{var}`
 is equivalent to `{var=*}`.

 The syntax `LITERAL` matches literal text in the URL path. If the `LITERAL`
 contains any reserved character, such characters should be percent-encoded
 before the matching.

 If a variable contains exactly one path segment, such as `"{var}"` or
 `"{var=*}"`, when such a variable is expanded into a URL path on the client
 side, all characters except `[-_.~0-9a-zA-Z]` are percent-encoded. The
 server side does the reverse decoding. Such variables show up in the
 [Discovery Document](https://developers.google.com/discovery/v1/reference/apis)
 as `{var}`.

 If a variable contains multiple path segments, such as `"{var=foo/*}"`
 or `"{var=**}"`, when such a variable is expanded into a URL path on the
 client side, all characters except `[-_.~/0-9a-zA-Z]` are percent-encoded.
 The server side does the reverse decoding, except "%2F" and "%2f" are left
 unchanged. Such variables show up in the
 [Discovery Document](https://developers.google.com/discovery/v1/reference/apis)
 as `{+var}`.

 ## Using gRPC API Service Configuration

 gRPC API Service Configuration (service config) is a configuration language
 for configuring a gRPC service to become a user-facing product. The
 service config is simply the YAML representation of the `google.api.Service`
 proto message.

 As an alternative to annotating your proto file, you can configure gRPC
 transcoding in your service config YAML files. You do this by specifying a
 `HttpRule` that maps the gRPC method to a REST endpoint, achieving the same
 effect as the proto annotation. This can be particularly useful if you
 have a proto that is reused in multiple services. Note that any transcoding
 specified in the service config will override any matching transcoding
 configuration in the proto.

 Example:

     http:
       rules:
         # Selects a gRPC method and applies HttpRule to it.
         - selector: example.v1.Messaging.GetMessage
           get: /v1/messages/{message_id}/{sub.subfield}

 ## Special notes

 When gRPC Transcoding is used to map a gRPC to JSON REST endpoints, the
 proto to JSON conversion must follow the [proto3
 specification](https://developers.google.com/protocol-buffers/docs/proto3#json).

 While the single segment variable follows the semantics of
 [RFC 6570](https://tools.ietf.org/html/rfc6570) Section 3.2.2 Simple String
 Expansion, the multi segment variable **does not** follow RFC 6570 Section
 3.2.3 Reserved Expansion. The reason is that the Reserved Expansion
 does not expand special characters like `?` and `#`, which would lead
 to invalid URLs. As the result, gRPC Transcoding uses a custom encoding
 for multi segment variables.

 The path variables **must not** refer to any repeated or mapped field,
 because client libraries are not capable of handling such variable expansion.

 The path variables **must not** capture the leading "/" character. The reason
 is that the most common use case "{var}" does not capture the leading "/"
 character. For consistency, all path variables must share the same behavior.

 Repeated message fields must not be mapped to URL query parameters, because
 no client library can support such complicated mapping.

 If an API needs to use a JSON array for request or response body, it can map
 the request or response body to a repeated field. However, some gRPC
 Transcoding implementations may not support this feature.


�
�
 � Selects a method to which this rule applies.

 Refer to [selector][google.api.DocumentationRule.selector] for syntax details.


 ��

 �

 �	

 �
�
 ��� Determines the URL pattern is matched by this rules. This pattern can be
 used with any of the {get|put|post|delete|patch} methods. A custom method
 can be defined using the 'custom' field.


 �
\
�N Maps to HTTP GET. Used for listing and getting information about
 resources.


�


�

�
@
�2 Maps to HTTP PUT. Used for replacing a resource.


�


�

�
X
�J Maps to HTTP POST. Used for creating a resource or performing an action.


�


�

�
B
�4 Maps to HTTP DELETE. Used for deleting a resource.


�


�

�
A
�3 Maps to HTTP PATCH. Used for updating a resource.


�


�

�
�
�!� The custom pattern is used for specifying an HTTP method that is not
 included in the `pattern` field, such as HEAD, or "*" to leave the
 HTTP method unspecified for this rule. The wild-card rule is useful
 for services that provide content to Web (HTML) clients.


�

�

� 
�
�� The name of the request field whose value is mapped to the HTTP request
 body, or `*` for mapping all request fields not captured by the path
 pattern to the HTTP body, or omitted for not having any HTTP request body.

 NOTE: the referred field must be present at the top-level of the request
 message type.


��

�

�	

�
�
�� Optional. The name of the response field whose value is mapped to the HTTP
 response body. When omitted, the entire response message will be used
 as the HTTP response body.

 NOTE: The referred field must be present at the top-level of the response
 message type.


��

�

�	

�
�
	�-� Additional HTTP bindings for the selector. Nested bindings must
 not contain an `additional_bindings` field themselves (that is,
 the nesting may only be one level deep).


	�


	�

	�'

	�*,
G
� �9 A custom pattern is used for defining custom HTTP verb.


�
2
 �$ The name of this custom HTTP verb.


 ��

 �

 �	

 �
5
�' The path matched by this custom verb.


��

�

�	

�bproto3
��
 google/protobuf/descriptor.protogoogle.protobuf"M
FileDescriptorSet8
file (2$.google.protobuf.FileDescriptorProtoRfile"�
FileDescriptorProto
name (	Rname
package (	Rpackage

dependency (	R
dependency+
public_dependency
 (RpublicDependency'
weak_dependency (RweakDependencyC
message_type (2 .google.protobuf.DescriptorProtoRmessageTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeA
service (2'.google.protobuf.ServiceDescriptorProtoRserviceC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extension6
options (2.google.protobuf.FileOptionsRoptionsI
source_code_info	 (2.google.protobuf.SourceCodeInfoRsourceCodeInfo
syntax (	Rsyntax"�
DescriptorProto
name (	Rname;
field (2%.google.protobuf.FieldDescriptorProtoRfieldC
	extension (2%.google.protobuf.FieldDescriptorProtoR	extensionA
nested_type (2 .google.protobuf.DescriptorProtoR
nestedTypeA
	enum_type (2$.google.protobuf.EnumDescriptorProtoRenumTypeX
extension_range (2/.google.protobuf.DescriptorProto.ExtensionRangeRextensionRangeD

oneof_decl (2%.google.protobuf.OneofDescriptorProtoR	oneofDecl9
options (2.google.protobuf.MessageOptionsRoptionsU
reserved_range	 (2..google.protobuf.DescriptorProto.ReservedRangeRreservedRange#
reserved_name
 (	RreservedNamez
ExtensionRange
start (Rstart
end (Rend@
options (2&.google.protobuf.ExtensionRangeOptionsRoptions7
ReservedRange
start (Rstart
end (Rend"|
ExtensionRangeOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
FieldDescriptorProto
name (	Rname
number (RnumberA
label (2+.google.protobuf.FieldDescriptorProto.LabelRlabel>
type (2*.google.protobuf.FieldDescriptorProto.TypeRtype
	type_name (	RtypeName
extendee (	Rextendee#
default_value (	RdefaultValue
oneof_index	 (R
oneofIndex
	json_name
 (	RjsonName7
options (2.google.protobuf.FieldOptionsRoptions"�
Type
TYPE_DOUBLE

TYPE_FLOAT

TYPE_INT64
TYPE_UINT64

TYPE_INT32
TYPE_FIXED64
TYPE_FIXED32
	TYPE_BOOL
TYPE_STRING	

TYPE_GROUP

TYPE_MESSAGE

TYPE_BYTES
TYPE_UINT32
	TYPE_ENUM
TYPE_SFIXED32
TYPE_SFIXED64
TYPE_SINT32
TYPE_SINT64"C
Label
LABEL_OPTIONAL
LABEL_REQUIRED
LABEL_REPEATED"c
OneofDescriptorProto
name (	Rname7
options (2.google.protobuf.OneofOptionsRoptions"�
EnumDescriptorProto
name (	Rname?
value (2).google.protobuf.EnumValueDescriptorProtoRvalue6
options (2.google.protobuf.EnumOptionsRoptions]
reserved_range (26.google.protobuf.EnumDescriptorProto.EnumReservedRangeRreservedRange#
reserved_name (	RreservedName;
EnumReservedRange
start (Rstart
end (Rend"�
EnumValueDescriptorProto
name (	Rname
number (Rnumber;
options (2!.google.protobuf.EnumValueOptionsRoptions"�
ServiceDescriptorProto
name (	Rname>
method (2&.google.protobuf.MethodDescriptorProtoRmethod9
options (2.google.protobuf.ServiceOptionsRoptions"�
MethodDescriptorProto
name (	Rname

input_type (	R	inputType
output_type (	R
outputType8
options (2.google.protobuf.MethodOptionsRoptions0
client_streaming (:falseRclientStreaming0
server_streaming (:falseRserverStreaming"�	
FileOptions!
java_package (	RjavaPackage0
java_outer_classname (	RjavaOuterClassname5
java_multiple_files
 (:falseRjavaMultipleFilesD
java_generate_equals_and_hash (BRjavaGenerateEqualsAndHash:
java_string_check_utf8 (:falseRjavaStringCheckUtf8S
optimize_for	 (2).google.protobuf.FileOptions.OptimizeMode:SPEEDRoptimizeFor

go_package (	R	goPackage5
cc_generic_services (:falseRccGenericServices9
java_generic_services (:falseRjavaGenericServices5
py_generic_services (:falseRpyGenericServices7
php_generic_services* (:falseRphpGenericServices%

deprecated (:falseR
deprecated/
cc_enable_arenas (:falseRccEnableArenas*
objc_class_prefix$ (	RobjcClassPrefix)
csharp_namespace% (	RcsharpNamespace!
swift_prefix' (	RswiftPrefix(
php_class_prefix( (	RphpClassPrefix#
php_namespace) (	RphpNamespace4
php_metadata_namespace, (	RphpMetadataNamespace!
ruby_package- (	RrubyPackageX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption":
OptimizeMode	
SPEED
	CODE_SIZE
LITE_RUNTIME*	�����J&'"�
MessageOptions<
message_set_wire_format (:falseRmessageSetWireFormatL
no_standard_descriptor_accessor (:falseRnoStandardDescriptorAccessor%

deprecated (:falseR
deprecated
	map_entry (RmapEntryX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J	J	
"�
FieldOptionsA
ctype (2#.google.protobuf.FieldOptions.CType:STRINGRctype
packed (RpackedG
jstype (2$.google.protobuf.FieldOptions.JSType:	JS_NORMALRjstype
lazy (:falseRlazy%

deprecated (:falseR
deprecated
weak
 (:falseRweakX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"/
CType

STRING 
CORD
STRING_PIECE"5
JSType
	JS_NORMAL 
	JS_STRING
	JS_NUMBER*	�����J"s
OneofOptionsX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
EnumOptions
allow_alias (R
allowAlias%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����J"�
EnumValueOptions%

deprecated (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
ServiceOptions%

deprecated! (:falseR
deprecatedX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption*	�����"�
MethodOptions%

deprecated! (:falseR
deprecatedq
idempotency_level" (2/.google.protobuf.MethodOptions.IdempotencyLevel:IDEMPOTENCY_UNKNOWNRidempotencyLevelX
uninterpreted_option� (2$.google.protobuf.UninterpretedOptionRuninterpretedOption"P
IdempotencyLevel
IDEMPOTENCY_UNKNOWN 
NO_SIDE_EFFECTS

IDEMPOTENT*	�����"�
UninterpretedOptionA
name (2-.google.protobuf.UninterpretedOption.NamePartRname)
identifier_value (	RidentifierValue,
positive_int_value (RpositiveIntValue,
negative_int_value (RnegativeIntValue!
double_value (RdoubleValue!
string_value (RstringValue'
aggregate_value (	RaggregateValueJ
NamePart
	name_part (	RnamePart!
is_extension (RisExtension"�
SourceCodeInfoD
location (2(.google.protobuf.SourceCodeInfo.LocationRlocation�
Location
path (BRpath
span (BRspan)
leading_comments (	RleadingComments+
trailing_comments (	RtrailingComments:
leading_detached_comments (	RleadingDetachedComments"�
GeneratedCodeInfoM

annotation (2-.google.protobuf.GeneratedCodeInfo.AnnotationR
annotationm

Annotation
path (BRpath
source_file (	R
sourceFile
begin (Rbegin
end (RendB�
com.google.protobufBDescriptorProtosHZ>github.com/golang/protobuf/protoc-gen-go/descriptor;descriptor��GPB�Google.Protobuf.ReflectionJ��
' �
�
' 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
2� Author: kenton@google.com (Kenton Varda)
  Based on original Protocol Buffers design by
  Sanjay Ghemawat, Jeff Dean, and others.

 The messages in this file describe the definitions found in .proto files.
 A valid .proto file can be translated directly to a FileDescriptorProto
 without any other information (e.g. without reading its imports).


)

* U
	
* U

+ ,
	
+ ,

, 1
	
, 1

- 7
	
%- 7

. !
	
$. !

/ 
	
/ 

3 

	3 t descriptor.proto must be optimized for speed because reflection-based
 algorithms don't work during bootstrapping.

j
 7 9^ The protocol compiler can output a FileDescriptorSet containing the .proto
 files it parses.



 7

  8(

  8


  8

  8#

  8&'
/
< Y# Describes a complete .proto file.



<
9
 =", file name, relative to root of source tree


 =


 =

 =

 =
*
>" e.g. "foo", "foo.bar", etc.


>


>

>

>
4
A!' Names of files imported by this file.


A


A

A

A 
Q
C(D Indexes of the public imported files in the dependency list above.


C


C

C"

C%'
z
F&m Indexes of the weak imported files in the dependency list.
 For Google-internal migration only. Do not use.


F


F

F 

F#%
6
I,) All top-level definitions in this file.


I


I

I'

I*+

J-

J


J

J(

J+,

K.

K


K!

K")

K,-

L.

L


L

L )

L,-

	N#

	N


	N

	N

	N!"
�

T/� This field contains optional information about the original source code.
 You may safely remove this entire field without harming runtime
 functionality of the descriptors -- the information is needed only by
 development tools.



T



T


T*


T-.
]
XP The syntax of the proto file.
 The supported values are "proto2" and "proto3".


X


X

X

X
'
\ | Describes a message type.



\

 ]

 ]


 ]

 ]

 ]

_*

_


_

_ %

_()

`.

`


`

` )

`,-

b+

b


b

b&

b)*

c-

c


c

c(

c+,

 ej

 e


  f

  f

  f

  f

  f

 g

 g

 g

 g

 g

 i/

 i

 i"

 i#*

 i-.

k.

k


k

k)

k,-

m/

m


m

m *

m-.

o&

o


o

o!

o$%
�
tw� Range of reserved tag numbers. Reserved tag numbers may not be used by
 fields or extension ranges in the same message. Reserved ranges may
 not overlap.


t


 u" Inclusive.


 u

 u

 u

 u

v" Exclusive.


v

v

v

v

x,

x


x

x'

x*+
�
	{%u Reserved field names, which may not be used by fields in the same message.
 A given name may only be reserved once.


	{


	{

	{

	{"$

~ �


~
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
3
� �% Describes a field within a message.


�

 ��

 �
S
  �C 0 is reserved for errors.
 Order is weird for historical reasons.


  �

  �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT64 if
 negative values are likely.


 �

 �

 �

 �

 �
w
 �g Not ZigZag encoded.  Negative numbers take 10 bytes.  Use TYPE_SINT32 if
 negative values are likely.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
�
 	�� Tag-delimited aggregate.
 Group type is deprecated and not supported in proto3. However, Proto3
 implementations should still be able to parse the group wire format and
 treat group fields as unknown fields.


 	�

 	�
-
 
�" Length-delimited aggregate.


 
�

 
�
#
 � New in version 2.


 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �
'
 �" Uses ZigZag encoding.


 �

 �
'
 �" Uses ZigZag encoding.


 �

 �

��

�
*
 � 0 is reserved for errors


 �

 �

�

�

�

�

�

�

 �

 �


 �

 �

 �

�

�


�

�

�

�

�


�

�

�
�
�� If type_name is set, this need not be set.  If both this and type_name
 are set, this must be one of TYPE_ENUM, TYPE_MESSAGE or TYPE_GROUP.


�


�

�

�
�
� � For message and enum types, this is the name of the type.  If the name
 starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
 rules are used to find the type (i.e. first the nested types within this
 message are searched, then within the parent, on up to the root
 namespace).


�


�

�

�
~
�p For extensions, this is the name of the type being extended.  It is
 resolved in the same manner as type_name.


�


�

�

�
�
�$� For numeric types, contains the original text representation of the value.
 For booleans, "true" or "false".
 For strings, contains the default text contents (not escaped in any way).
 For bytes, contains the C escaped value.  All bytes >= 128 are escaped.
 TODO(kenton):  Base-64 encode?


�


�

�

�"#
�
�!v If set, gives the index of a oneof in the containing type's oneof_decl
 list.  This field is a member of that oneof.


�


�

�

� 
�
�!� JSON name of this field. The value is set by protocol compiler. If the
 user has set a "json_name" option on this field, that option's value
 will be used. Otherwise, it's deduced from the field's name by converting
 it to camelCase.


�


�

�

� 

	�$

	�


	�

	�

	�"#
"
� � Describes a oneof.


�

 �

 �


 �

 �

 �

�$

�


�

�

�"#
'
� � Describes an enum type.


�

 �

 �


 �

 �

 �

�.

�


�#

�$)

�,-

�#

�


�

�

�!"
�
 ��� Range of reserved numeric values. Reserved values may not be used by
 entries in the same enum. Reserved ranges may not overlap.

 Note that this is distinct from DescriptorProto.ReservedRange in that it
 is inclusive such that it can appropriately represent the entire int32
 domain.


 �


  �" Inclusive.


  �

  �

  �

  �

 �" Inclusive.


 �

 �

 �

 �
�
�0� Range of reserved numeric values. Reserved numeric values may not be used
 by enum values in the same enum declaration. Reserved ranges may not
 overlap.


�


�

�+

�./
l
�$^ Reserved enum value names, which may not be reused. A given name may only
 be reserved once.


�


�

�

�"#
1
� �# Describes a value within an enum.


� 

 �

 �


 �

 �

 �

�

�


�

�

�

�(

�


�

�#

�&'
$
� � Describes a service.


�

 �

 �


 �

 �

 �

�,

�


� 

�!'

�*+

�&

�


�

�!

�$%
0
	� �" Describes a method of a service.


	�

	 �

	 �


	 �

	 �

	 �
�
	�!� Input and output type names.  These are resolved in the same way as
 FieldDescriptorProto.type_name, but must refer to a message type.


	�


	�

	�

	� 

	�"

	�


	�

	�

	� !

	�%

	�


	�

	� 

	�#$
E
	�57 Identifies if client streams multiple client messages


	�


	�

	� 

	�#$

	�%4

	�.3
E
	�57 Identifies if server streams multiple server messages


	�


	�

	� 

	�#$

	�%4

	�.3
�

� �2N ===================================================================
 Options
2� Each of the definitions above may have "options" attached.  These are
 just annotations which may cause code to be generated slightly differently
 or may contain hints for code that manipulates protocol messages.

 Clients may define custom options as extensions of the *Options messages.
 These extensions may not yet be known at parsing time, so the parser cannot
 store the values in them.  Instead it stores them in a field in the *Options
 message called uninterpreted_option. This field must have the same name
 across all *Options messages. We then use this field to populate the
 extensions when we build a descriptor, at which point all protos have been
 parsed and so all extensions are known.

 Extension numbers for custom options may be chosen as follows:
 * For options which will only be used within a single application or
   organization, or for experimental options, use field numbers 50000
   through 99999.  It is up to you to ensure that you do not use the
   same number for multiple options.
 * For options which will be published and used publicly by multiple
   independent entities, e-mail protobuf-global-extension-registry@google.com
   to reserve extension numbers. Simply provide your project name (e.g.
   Objective-C plugin) and your project website (if available) -- there's no
   need to explain how you intend to use them. Usually you only need one
   extension number. You can declare multiple options with only one extension
   number by putting them in a sub-message. See the Custom Options section of
   the docs for examples:
   https://developers.google.com/protocol-buffers/docs/proto#options
   If this turns out to be popular, a web service will be set up
   to automatically assign option numbers.



�
�

 �#� Sets the Java package where classes generated from this .proto will be
 placed.  By default, the proto package is used, but this is often
 inappropriate because proto packages do not normally start with backwards
 domain names.



 �



 �


 �


 �!"
�

�+� If set, all the classes from the .proto file are wrapped in a single
 outer class with the given name.  This applies to both Proto1
 (equivalent to the old "--one_java_file" option) and Proto2 (where
 a .proto always translates to a single class, but you may want to
 explicitly choose the class name).



�



�


�&


�)*
�

�9� If set true, then the Java code generator will generate a separate .java
 file for each top-level message, enum, and service defined in the .proto
 file.  Thus, these types will *not* be nested inside the outer class
 named by java_outer_classname.  However, the outer class will still be
 generated to contain the file's getDescriptor() method as well as any
 top-level extensions defined in the file.



�



�


�#


�&(


�)8


�27
)

�E This option does nothing.



�



�


�-


�02


�3D


�4C
�

�<� If set true, then the Java2 code generator will generate code that
 throws an exception whenever an attempt is made to assign a non-UTF-8
 byte sequence to a string field.
 Message reflection will do the same.
 However, an extension field still accepts non-UTF-8 byte sequences.
 This option has no effect on when used with the lite runtime.



�



�


�&


�)+


�,;


�5:
L

 ��< Generated classes can be optimized for speed or code size.



 �
D

  �"4 Generate complete code for parsing, serialization,



  �	


  �
G

 � etc.
"/ Use ReflectionOps to implement these methods.



 �


 �
G

 �"7 Generate code using MessageLite and the lite runtime.



 �


 �


�9


�



�


�$


�'(


�)8


�27
�

�"� Sets the Go package where structs generated from this .proto will be
 placed. If omitted, the Go package will be derived from the following:
   - The basename of the package import path, if provided.
   - Otherwise, the package statement in the .proto file, if present.
   - Otherwise, the basename of the .proto file, without extension.



�



�


�


�!
�

�9� Should generic services be generated in each language?  "Generic" services
 are not specific to any particular RPC system.  They are generated by the
 main code generators in each language (without additional plugins).
 Generic services were the only kind of service generation supported by
 early versions of google.protobuf.

 Generic services are now considered deprecated in favor of using plugins
 that generate code specific to your particular RPC system.  Therefore,
 these default to false.  Old code which depends on generic services should
 explicitly set them to true.



�



�


�#


�&(


�)8


�27


�;


�



�


�%


�(*


�+:


�49


	�9


	�



	�


	�#


	�&(


	�)8


	�27



�:



�




�



�$



�')



�*9



�38
�

�0� Is this file deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for everything in the file, or it will be completely ignored; in the very
 least, this is a formalization for deprecating files.



�



�


�


�


� /


�).


�6q Enables the use of arenas for the proto messages in this file. This applies
 only to generated classes for C++.



�



�


� 


�#%


�&5


�/4
�

�)� Sets the objective c class prefix which is prepended to all objective c
 generated classes from this .proto. There is no default.



�



�


�#


�&(
I

�(; Namespace for generated classes; defaults to the package.



�



�


�"


�%'
�

�$� By default Swift generators will take the proto package and CamelCase it
 replacing '.' with underscore and use that to prefix the types/symbols
 defined. When this options is provided, they will use this value instead
 to prefix the types/symbols defined.



�



�


�


�!#
~

�(p Sets the php class prefix which is prepended to all php generated classes
 from this .proto. Default is empty.



�



�


�"


�%'
�

�%� Use this option to change the namespace of php generated classes. Default
 is empty. When this option is empty, the package name will be used for
 determining the namespace.



�



�


�


�"$
�

�.� Use this option to change the namespace of php generated metadata classes.
 Default is empty. When this option is empty, the proto file name will be used
 for determining the namespace.



�



�


�(


�+-
�

�$� Use this option to change the package of ruby generated classes. Default
 is empty. When this option is not set, the package name will be used for
 determining the ruby package.



�



�


�


�!#
|

�:n The parser stores options it doesn't recognize here.
 See the documentation for the "Options" section above.



�



�


�3


�69
�

�z Clients can define custom options in extensions of this message.
 See the documentation for the "Options" section above.



 �


 �


 �


	�


	 �


	 �


	 �

� �

�
�
 �<� Set true to use the old proto1 MessageSet wire format for extensions.
 This is provided for backwards-compatibility with the MessageSet wire
 format.  You should not use this for any other reason:  It's less
 efficient, has fewer features, and is more complicated.

 The message must be defined exactly as follows:
   message Foo {
     option message_set_wire_format = true;
     extensions 4 to max;
   }
 Note that the message cannot have any defined fields; MessageSets only
 have extensions.

 All extensions of your type must be singular messages; e.g. they cannot
 be int32s, enums, or repeated messages.

 Because this is an option, the above two restrictions are not enforced by
 the protocol compiler.


 �


 �

 �'

 �*+

 �,;

 �5:
�
�D� Disables the generation of the standard "descriptor()" accessor, which can
 conflict with a field of the same name.  This is meant to make migration
 from proto1 easier; new code should avoid fields named "descriptor".


�


�

�/

�23

�4C

�=B
�
�/� Is this message deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the message, or it will be completely ignored; in the very least,
 this is a formalization for deprecating messages.


�


�

�

�

�.

�(-
�
�� Whether the message is an automatically generated map entry type for the
 maps field.

 For maps fields:
     map<KeyType, ValueType> map_field = 1;
 The parsed descriptor looks like:
     message MapFieldEntry {
         option map_entry = true;
         optional KeyType key = 1;
         optional ValueType value = 2;
     }
     repeated MapFieldEntry map_field = 1;

 Implementations may choose not to generate the map_entry=true message, but
 use a native map in the target language to hold the keys and values.
 The reflection APIs in such implementions still need to work as
 if the field is a repeated message field.

 NOTE: Do not set the option in .proto files. Always use the maps syntax
 instead. The option should only be implicitly set by the proto compiler
 parser.


�


�

�

�
$
	�" javalite_serializable


	 �

	 �

	 �

	�" javanano_as_lite


	�

	�

	�
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �.� The ctype option instructs the C++ code generator to use a different
 representation of the field than it normally would.  See the specific
 options below.  This option is not yet implemented in the open source
 release -- sorry, we'll try to include it in a future version!


 �


 �

 �

 �

 �-

 �&,

 ��

 �

  � Default mode.


  �


  �

 �

 �

 �

 �

 �

 �
�
�� The packed option can be enabled for repeated primitive fields to enable
 a more efficient representation on the wire. Rather than repeatedly
 writing the tag and type for each element, the entire array is encoded as
 a single length-delimited blob. In proto3, only explicit setting it to
 false will avoid using packed encoding.


�


�

�

�
�
�3� The jstype option determines the JavaScript type used for values of the
 field.  The option is permitted only for 64 bit integral and fixed types
 (int64, uint64, sint64, fixed64, sfixed64).  A field with jstype JS_STRING
 is represented as JavaScript string, which avoids loss of precision that
 can happen when a large value is converted to a floating point JavaScript.
 Specifying JS_NUMBER for the jstype causes the generated JavaScript code to
 use the JavaScript "number" type.  The behavior of the default option
 JS_NORMAL is implementation dependent.

 This option is an enum to permit additional types to be added, e.g.
 goog.math.Integer.


�


�

�

�

�2

�(1

��

�
'
 � Use the default type.


 �

 �
)
� Use JavaScript strings.


�

�
)
� Use JavaScript numbers.


�

�
�
�)� Should this field be parsed lazily?  Lazy applies only to message-type
 fields.  It means that when the outer message is initially parsed, the
 inner message's contents will not be parsed but instead stored in encoded
 form.  The inner message will actually be parsed when it is first accessed.

 This is only a hint.  Implementations are free to choose whether to use
 eager or lazy parsing regardless of the value of this option.  However,
 setting this option true suggests that the protocol author believes that
 using lazy parsing on this field is worth the additional bookkeeping
 overhead typically needed to implement it.

 This option does not affect the public interface of any generated code;
 all method signatures remain the same.  Furthermore, thread-safety of the
 interface is not affected by this option; const methods remain safe to
 call from multiple threads concurrently, while non-const methods continue
 to require exclusive access.


 Note that implementations may choose not to check required fields within
 a lazy sub-message.  That is, calling IsInitialized() on the outer message
 may return true even if the inner message has missing required fields.
 This is necessary because otherwise the inner message would have to be
 parsed in order to perform the check, defeating the purpose of lazy
 parsing.  An implementation which chooses not to check required fields
 must be consistent about it.  That is, for any particular sub-message, the
 implementation must either *always* check its required fields, or *never*
 check its required fields, regardless of whether or not the message has
 been parsed.


�


�

�

�

�(

�"'
�
�/� Is this field deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for accessors, or it will be completely ignored; in the very least, this
 is a formalization for deprecating fields.


�


�

�

�

�.

�(-
?
�*1 For Google-internal migration only. Do not use.


�


�

�

�

�)

�#(
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

	�" removed jtype


	 �

	 �

	 �

� �

�
O
 �:A The parser stores options it doesn't recognize here. See above.


 �


 �

 �3

 �69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
`
 � R Set this option to true to allow mapping different tag names to the same
 value.


 �


 �

 �

 �
�
�/� Is this enum deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum, or it will be completely ignored; in the very least, this
 is a formalization for deprecating enums.


�


�

�

�

�.

�(-

	�" javanano_as_lite


	 �

	 �

	 �
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �/� Is this enum value deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the enum value, or it will be completely ignored; in the very least,
 this is a formalization for deprecating enum values.


 �


 �

 �

 �

 �.

 �(-
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �0� Is this service deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the service, or it will be completely ignored; in the very least,
 this is a formalization for deprecating services.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � /

 �).
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �

� �

�
�
 �0� Is this method deprecated?
 Depending on the target platform, this can emit Deprecated annotations
 for the method, or it will be completely ignored; in the very least,
 this is a formalization for deprecating methods.
2� Note:  Field numbers 1 through 32 are reserved for Google's internal RPC
   framework.  We apologize for hoarding these numbers to ourselves, but
   we were already using them long before we decided to release Protocol
   Buffers.


 �


 �

 �

 �

 � /

 �).
�
 ��� Is this method side-effect-free (or safe in HTTP parlance), or idempotent,
 or neither? HTTP based RPC implementation may choose GET verb for safe
 methods, and PUT verb for idempotent methods instead of the default POST.


 �

  �

  �

  �
$
 �" implies idempotent


 �

 �
7
 �"' idempotent, but may have side effects


 �

 �

��'

�


�

�-

�

�	&

�%
O
�:A The parser stores options it doesn't recognize here. See above.


�


�

�3

�69
Z
�M Clients can define custom options in extensions of this message. See above.


 �

 �

 �
�
� �� A message representing a option the parser does not recognize. This only
 appears in options protos created by the compiler::Parser class.
 DescriptorPool resolves these when building Descriptor objects. Therefore,
 options protos in descriptor objects (e.g. returned by Descriptor::options(),
 or produced by Descriptor::CopyTo()) will never have UninterpretedOptions
 in them.


�
�
 ��� The name of the uninterpreted option.  Each string represents a segment in
 a dot-separated name.  is_extension is true iff a segment represents an
 extension (denoted with parentheses in options specs in .proto files).
 E.g.,{ ["foo", false], ["bar.baz", true], ["qux", false] } represents
 "foo.(bar.baz).qux".


 �


  �"

  �

  �

  �

  � !

 �#

 �

 �

 �

 �!"

 �

 �


 �

 �

 �
�
�'� The value of the uninterpreted option, in whatever type the tokenizer
 identified it as during parsing. Exactly one of these should be set.


�


�

�"

�%&

�)

�


�

�$

�'(

�(

�


�

�#

�&'

�#

�


�

�

�!"

�"

�


�

�

� !

�&

�


�

�!

�$%
�
� �j Encapsulates information about the original source file from which a
 FileDescriptorProto was generated.
2` ===================================================================
 Optional source code info


�
�
 �!� A Location identifies a piece of source code in a .proto file which
 corresponds to a particular definition.  This information is intended
 to be useful to IDEs, code indexers, documentation generators, and similar
 tools.

 For example, say we have a file like:
   message Foo {
     optional string foo = 1;
   }
 Let's look at just the field definition:
   optional string foo = 1;
   ^       ^^     ^^  ^  ^^^
   a       bc     de  f  ghi
 We have the following locations:
   span   path               represents
   [a,i)  [ 4, 0, 2, 0 ]     The whole field definition.
   [a,b)  [ 4, 0, 2, 0, 4 ]  The label (optional).
   [c,d)  [ 4, 0, 2, 0, 5 ]  The type (string).
   [e,f)  [ 4, 0, 2, 0, 1 ]  The name (foo).
   [g,h)  [ 4, 0, 2, 0, 3 ]  The number (1).

 Notes:
 - A location may refer to a repeated field itself (i.e. not to any
   particular index within it).  This is used whenever a set of elements are
   logically enclosed in a single code segment.  For example, an entire
   extend block (possibly containing multiple extension definitions) will
   have an outer location whose path refers to the "extensions" repeated
   field without an index.
 - Multiple locations may have the same path.  This happens when a single
   logical declaration is spread out across multiple places.  The most
   obvious example is the "extend" block again -- there may be multiple
   extend blocks in the same scope, each of which will have the same path.
 - A location's span is not always a subset of its parent's span.  For
   example, the "extendee" of an extension declaration appears at the
   beginning of the "extend" block and is shared by all extensions within
   the block.
 - Just because a location's span is a subset of some other location's span
   does not mean that it is a descendent.  For example, a "group" defines
   both a type and a field in a single declaration.  Thus, the locations
   corresponding to the type and field and their components will overlap.
 - Code which tries to interpret locations should probably be designed to
   ignore those that it doesn't understand, as more types of locations could
   be recorded in the future.


 �


 �

 �

 � 

 ��

 �

�
  �*� Identifies which part of the FileDescriptorProto was defined at this
 location.

 Each element is a field number or an index.  They form a path from
 the root FileDescriptorProto to the place where the definition.  For
 example, this path:
   [ 4, 3, 2, 7, 1 ]
 refers to:
   file.message_type(3)  // 4, 3
       .field(7)         // 2, 7
       .name()           // 1
 This is because FileDescriptorProto.message_type has field number 4:
   repeated DescriptorProto message_type = 4;
 and DescriptorProto.field has field number 2:
   repeated FieldDescriptorProto field = 2;
 and FieldDescriptorProto.name has field number 1:
   optional string name = 1;

 Thus, the above path gives the location of a field name.  If we removed
 the last element:
   [ 4, 3, 2, 7 ]
 this path refers to the whole field declaration (from the beginning
 of the label to the terminating semicolon).


  �

  �

  �

  �

  �)

  �(
�
 �*� Always has exactly three or four elements: start line, start column,
 end line (optional, otherwise assumed same as start line), end column.
 These are packed into a single field for efficiency.  Note that line
 and column numbers are zero-based -- typically you will want to add
 1 to each before displaying to a user.


 �

 �

 �

 �

 �)

 �(
�
 �)� If this SourceCodeInfo represents a complete declaration, these are any
 comments appearing before and after the declaration which appear to be
 attached to the declaration.

 A series of line comments appearing on consecutive lines, with no other
 tokens appearing on those lines, will be treated as a single comment.

 leading_detached_comments will keep paragraphs of comments that appear
 before (but not connected to) the current element. Each paragraph,
 separated by empty lines, will be one comment element in the repeated
 field.

 Only the comment content is provided; comment markers (e.g. //) are
 stripped out.  For block comments, leading whitespace and an asterisk
 will be stripped from the beginning of each line other than the first.
 Newlines are included in the output.

 Examples:

   optional int32 foo = 1;  // Comment attached to foo.
   // Comment attached to bar.
   optional int32 bar = 2;

   optional string baz = 3;
   // Comment attached to baz.
   // Another line attached to baz.

   // Comment attached to qux.
   //
   // Another line attached to qux.
   optional double qux = 4;

   // Detached comment for corge. This is not leading or trailing comments
   // to qux or corge because there are blank lines separating it from
   // both.

   // Detached comment for corge paragraph 2.

   optional string corge = 5;
   /* Block comment attached
    * to corge.  Leading asterisks
    * will be removed. */
   /* Block comment attached to
    * grault. */
   optional int32 grault = 6;

   // ignored detached comments.


 �

 �

 �$

 �'(

 �*

 �

 �

 �%

 �()

 �2

 �

 �

 �-

 �01
�
� �� Describes the relationship between generated code and its original source
 file. A GeneratedCodeInfo message is associated with only one generated
 source file, but may contain references to different source .proto files.


�
x
 �%j An Annotation connects some span of text in generated code to an element
 of its generating .proto file.


 �


 �

 � 

 �#$

 ��

 �

�
  �* Identifies the element in the original source .proto file. This field
 is formatted the same as SourceCodeInfo.Location.path.


  �

  �

  �

  �

  �)

  �(
O
 �$? Identifies the filesystem path to the original source .proto.


 �

 �

 �

 �"#
w
 �g Identifies the starting offset in bytes in the generated code
 that relates to the identified object.


 �

 �

 �

 �
�
 �� Identifies the ending offset in bytes in the generated code that
 relates to the identified offset. The end offset should be one past
 the last relevant byte (so the length of the text = end - begin).


 �

 �

 �

 �
�
google/api/annotations.proto
google.apigoogle/api/http.proto google/protobuf/descriptor.proto:K
http.google.protobuf.MethodOptions�ʼ" (2.google.api.HttpRuleRhttpBn
com.google.apiBAnnotationsProtoPZAgoogle.golang.org/genproto/googleapis/api/annotations;annotations�GAPIJ�
 
�
 2� Copyright (c) 2015, Google Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.



	
 
	
)

 X
	
 X

 "
	

 "

 1
	
 1

 '
	
 '

 "
	
$ "
	
 

  See `HttpRule`.



 $

 &


 



 


 bproto3
�'

cart.proto	coolstoregoogle/api/annotations.proto"Z

ProductDto
id (	Rid
name (	Rname
desc (	Rdesc
price (Rprice"�
CartDto
id (	Rid&
cart_item_total (RcartItemTotal5
cart_item_promo_savings (RcartItemPromoSavings%
shipping_total (RshippingTotal4
shipping_promo_savings (RshippingPromoSavings

cart_total (R	cartTotal 
is_check_out (R
isCheckOut,
items (2.coolstore.CartItemDtoRitems"�
CartItemDto
quantity (Rquantity
price (Rprice#
promo_savings (RpromoSavings

product_id (	R	productId!
product_name (	RproductName")
GetCartRequest
cart_id (	RcartId"=
GetCartResponse*
result (2.coolstore.CartDtoRresult"W
InsertItemToNewCartRequest

product_id (	R	productId
quantity (Rquantity"I
InsertItemToNewCartResponse*
result (2.coolstore.CartDtoRresult"m
UpdateItemInCartRequest
cart_id (	RcartId

product_id (	R	productId
quantity (Rquantity"F
UpdateItemInCartResponse*
result (2.coolstore.CartDtoRresult"K
DeleteItemRequest
cart_id (	RcartId

product_id (	R	productId"3
DeleteItemResponse

product_id (	R	productId"*
CheckoutRequest
cart_id (	RcartId"1
CheckoutResponse

is_succeed (R	isSucceed2�
CartServicec
GetCart.coolstore.GetCartRequest.coolstore.GetCartResponse"!���/cart/api/carts/{cart_id}�
InsertItemToNewCart%.coolstore.InsertItemToNewCartRequest&.coolstore.InsertItemToNewCartResponse"���"/cart/api/carts:*w
UpdateItemInCart".coolstore.UpdateItemInCartRequest#.coolstore.UpdateItemInCartResponse"���/cart/api/carts:*o
Checkout.coolstore.CheckoutRequest.coolstore.CheckoutResponse"*���$"/cart/api/carts/{cart_id}/checkout

DeleteItem.coolstore.DeleteItemRequest.coolstore.DeleteItemResponse"4���.*,/cart/api/carts/{cart_id}/items/{product_id}B&�#VND.CoolStore.Services.Cart.v1.GrpcJ�
  h

  



 @
	
% @
	
 %


  "


 

  

  

  

  '6

  


	  �ʼ"


 

 

 4

 ?Z

 

	 �ʼ"

 

 

 .

 9Q

 

	 �ʼ"

 

 

 

 )9

 

	 �ʼ"

 !

 

 "

 -?

  

	 �ʼ" 


 $ )


 $

  %

  %$

  %

  %	

  %

 &

 &%

 &

 &	

 &

 '

 '&

 '

 '	

 '

 (

 ('

 (

 (	

 (


+ 4


+

 ,

 ,+

 ,

 ,	

 ,

-

-,

-

-	

-

.%

.-

.

.	 

.#$

/

/.%

/

/	

/

0$

0/

0

0	

0"#

1

10$

1

1	

1

2

21

2

2

2

3!

3


3

3

3 


6 <


6

 7

 76

 7

 7

 7

8

87

8

8	

8

9

98

9

9	

9

:

:9

:

:	

:

;

;:

;

;	

;


> @


>

 ?

 ?>

 ?

 ?	

 ?


B D


B

 C

 CB

 C	

 C


 C


F I


F"

 G

 GF$

 G

 G	

 G

H

HG

H

H

H


K M


K#

 L

 LK%

 L	

 L


 L


O S


O

 P

 PO!

 P

 P	

 P

Q

QP

Q

Q	

Q

R

RQ

R

R

R


U W


U 

 V

 VU"

 V	

 V


 V


	Y \


	Y

	 Z

	 ZY

	 Z

	 Z	

	 Z

	[

	[Z

	[

	[	

	[



^ `



^


 _


 _^


 _


 _	


 _


b d


b

 c

 cb

 c

 c	

 c


f h


f

 g

 gf

 g

 g

 gbproto3
�
catalog.proto	coolstoregoogle/api/annotations.proto"~
CatalogProductDto
id (	Rid
name (	Rname
desc (	Rdesc
price (Rprice
	image_url (	RimageUrl"V
GetProductsRequest!
current_page (RcurrentPage

high_price (R	highPrice"O
GetProductsResponse8
products (2.coolstore.CatalogProductDtoRproducts"6
GetProductByIdRequest

product_id (	R	productId"P
GetProductByIdResponse6
product (2.coolstore.CatalogProductDtoRproduct"q
CreateProductRequest
name (	Rname
desc (	Rdesc
price (Rprice
	image_url (	RimageUrl"O
CreateProductResponse6
product (2.coolstore.CatalogProductDtoRproduct2�
CatalogService�
GetProducts.coolstore.GetProductsRequest.coolstore.GetProductsResponse"9���31/catalog/api/products/{current_page}/{high_price}�
GetProductById .coolstore.GetProductByIdRequest!.coolstore.GetProductByIdResponse"*���$"/catalog/api/products/{product_id}t
CreateProduct.coolstore.CreateProductRequest .coolstore.CreateProductResponse" ���"/catalog/api/products:*B)�&VND.CoolStore.Services.Catalog.v1.GrpcJ�
  ;

  



 C
	
% C
	
 %


  


 

  

  

  $

  /B

  


	  �ʼ"


 

 

 *

 5K

 

	 �ʼ"

 

 

 (

 3H

 

	 �ʼ"


  


 

  

  

  

  	

  

 

 

 

 	

 

 

 

 

 	

 

 

 

 

 	

 

 

 

 

 	

 


! $


!

 "

 "!

 "

 "

 "

#

#"

#

#	

#


& (


&

 '*

 '


 '

 '%

 '()


* ,


*

 +

 +*

 +

 +	

 +


. 0


.

 / 

 /. 

 /

 /

 /


2 7


2

 3

 32

 3

 3	

 3

4

43

4

4	

4

5

54

5

5	

5

6

65

6

6	

6


9 ;


9

 : 

 :9

 :

 :

 :bproto3
�,
google/protobuf/any.protogoogle.protobuf"6
Any
type_url (	RtypeUrl
value (RvalueBo
com.google.protobufBAnyProtoPZ%github.com/golang/protobuf/ptypes/any�GPB�Google.Protobuf.WellKnownTypesJ�*
 �
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


 

" ;
	
%" ;

# <
	
# <

$ ,
	
$ ,

% )
	
% )

& "
	

& "

' !
	
$' !
�
 y �� `Any` contains an arbitrary serialized protocol buffer message along with a
 URL that describes the type of the serialized message.

 Protobuf library provides support to pack/unpack Any values in the form
 of utility functions or additional generated methods of the Any type.

 Example 1: Pack and unpack a message in C++.

     Foo foo = ...;
     Any any;
     any.PackFrom(foo);
     ...
     if (any.UnpackTo(&foo)) {
       ...
     }

 Example 2: Pack and unpack a message in Java.

     Foo foo = ...;
     Any any = Any.pack(foo);
     ...
     if (any.is(Foo.class)) {
       foo = any.unpack(Foo.class);
     }

  Example 3: Pack and unpack a message in Python.

     foo = Foo(...)
     any = Any()
     any.Pack(foo)
     ...
     if any.Is(Foo.DESCRIPTOR):
       any.Unpack(foo)
       ...

  Example 4: Pack and unpack a message in Go

      foo := &pb.Foo{...}
      any, err := ptypes.MarshalAny(foo)
      ...
      foo := &pb.Foo{}
      if err := ptypes.UnmarshalAny(any, foo); err != nil {
        ...
      }

 The pack methods provided by protobuf library will by default use
 'type.googleapis.com/full.type.name' as the type URL and the unpack
 methods only use the fully qualified type name after the last '/'
 in the type URL, for example "foo.bar.com/x/y.z" will yield type
 name "y.z".


 JSON
 ====
 The JSON representation of an `Any` value uses the regular
 representation of the deserialized, embedded message, with an
 additional field `@type` which contains the type URL. Example:

     package google.profile;
     message Person {
       string first_name = 1;
       string last_name = 2;
     }

     {
       "@type": "type.googleapis.com/google.profile.Person",
       "firstName": <string>,
       "lastName": <string>
     }

 If the embedded message type is well-known and has a custom JSON
 representation, that representation will be embedded adding a field
 `value` which holds the custom JSON in addition to the `@type`
 field. Example (for message [google.protobuf.Duration][]):

     {
       "@type": "type.googleapis.com/google.protobuf.Duration",
       "value": "1.212s"
     }




 y
�

  ��
 A URL/resource name that uniquely identifies the type of the serialized
 protocol buffer message. The last segment of the URL's path must represent
 the fully qualified name of the type (as in
 `path/google.protobuf.Duration`). The name should be in a canonical form
 (e.g., leading "." is not accepted).

 In practice, teams usually precompile into the binary all types that they
 expect it to use in the context of Any. However, for URLs which use the
 scheme `http`, `https`, or no scheme, one can optionally set up a type
 server that maps type URLs to message definitions as follows:

 * If no scheme is provided, `https` is assumed.
 * An HTTP GET on the URL must yield a [google.protobuf.Type][]
   value in binary format, or produce an error.
 * Applications are allowed to cache lookup results based on the
   URL, or have them precompiled into a binary to avoid any
   lookup. Therefore, binary compatibility needs to be preserved
   on changes to types. (Use versioned type names to manage
   breaking changes.)

 Note: this functionality is not currently available in the official
 protobuf release, and it is not used for type URLs beginning with
 type.googleapis.com.

 Schemes other than `http`, `https` (or the empty scheme) might be
 used with implementation specific semantics.



  �y

  �

  �	

  �
W
 �I Must be a valid serialized protocol buffer of the above specified type.


 ��

 �

 �

 �bproto3
��
*protoc-gen-swagger/options/openapiv2.proto'grpc.gateway.protoc_gen_swagger.optionsgoogle/protobuf/any.proto"�
Swagger
swagger (	RswaggerA
info (2-.grpc.gateway.protoc_gen_swagger.options.InfoRinfo
host (	Rhost
	base_path (	RbasePathX
schemes (2>.grpc.gateway.protoc_gen_swagger.options.Swagger.SwaggerSchemeRschemes
consumes (	Rconsumes
produces (	Rproduces]
	responses
 (2?.grpc.gateway.protoc_gen_swagger.options.Swagger.ResponsesEntryR	responseso
security_definitions (2<.grpc.gateway.protoc_gen_swagger.options.SecurityDefinitionsRsecurityDefinitionsX
security (2<.grpc.gateway.protoc_gen_swagger.options.SecurityRequirementRsecurityc
external_docs (2>.grpc.gateway.protoc_gen_swagger.options.ExternalDocumentationRexternalDocso
ResponsesEntry
key (	RkeyG
value (21.grpc.gateway.protoc_gen_swagger.options.ResponseRvalue:8"B
SwaggerScheme
UNKNOWN 
HTTP	
HTTPS
WS
WSSJ	J	
J"�
	Operation
tags (	Rtags
summary (	Rsummary 
description (	Rdescriptionc
external_docs (2>.grpc.gateway.protoc_gen_swagger.options.ExternalDocumentationRexternalDocs!
operation_id (	RoperationId
consumes (	Rconsumes
produces (	Rproduces_
	responses	 (2A.grpc.gateway.protoc_gen_swagger.options.Operation.ResponsesEntryR	responses
schemes
 (	Rschemes

deprecated (R
deprecatedX
security (2<.grpc.gateway.protoc_gen_swagger.options.SecurityRequirementRsecurityo
ResponsesEntry
key (	RkeyG
value (21.grpc.gateway.protoc_gen_swagger.options.ResponseRvalue:8J	"�
Response 
description (	RdescriptionG
schema (2/.grpc.gateway.protoc_gen_swagger.options.SchemaRschemaJJ"�
Info
title (	Rtitle 
description (	Rdescription(
terms_of_service (	RtermsOfServiceJ
contact (20.grpc.gateway.protoc_gen_swagger.options.ContactRcontactJ
license (20.grpc.gateway.protoc_gen_swagger.options.LicenseRlicense
version (	Rversion"E
Contact
name (	Rname
url (	Rurl
email (	Remail"/
License
name (	Rname
url (	Rurl"K
ExternalDocumentation 
description (	Rdescription
url (	Rurl"�
SchemaT
json_schema (23.grpc.gateway.protoc_gen_swagger.options.JSONSchemaR
jsonSchema$
discriminator (	Rdiscriminator
	read_only (RreadOnlyc
external_docs (2>.grpc.gateway.protoc_gen_swagger.options.ExternalDocumentationRexternalDocs.
example (2.google.protobuf.AnyRexampleJ"�

JSONSchema
ref (	Rref
title (	Rtitle 
description (	Rdescription
default (	Rdefault
multiple_of
 (R
multipleOf
maximum (Rmaximum+
exclusive_maximum (RexclusiveMaximum
minimum (Rminimum+
exclusive_minimum (RexclusiveMinimum

max_length (R	maxLength

min_length (R	minLength
pattern (	Rpattern
	max_items (RmaxItems
	min_items (RminItems!
unique_items (RuniqueItems%
max_properties (RmaxProperties%
min_properties (RminProperties
required (	Rrequired
array" (	Rarray]
type# (2I.grpc.gateway.protoc_gen_swagger.options.JSONSchema.JSONSchemaSimpleTypesRtype"w
JSONSchemaSimpleTypes
UNKNOWN 	
ARRAY
BOOLEAN
INTEGER
NULL

NUMBER

OBJECT

STRINGJJJJ	J	
JJJJJJJ"J$*J*+J+."�
Tag 
description (	Rdescriptionc
external_docs (2>.grpc.gateway.protoc_gen_swagger.options.ExternalDocumentationRexternalDocsJ"�
SecurityDefinitionsf
security (2J.grpc.gateway.protoc_gen_swagger.options.SecurityDefinitions.SecurityEntryRsecurityt
SecurityEntry
key (	RkeyM
value (27.grpc.gateway.protoc_gen_swagger.options.SecuritySchemeRvalue:8"�
SecuritySchemeP
type (2<.grpc.gateway.protoc_gen_swagger.options.SecurityScheme.TypeRtype 
description (	Rdescription
name (	RnameJ
in (2:.grpc.gateway.protoc_gen_swagger.options.SecurityScheme.InRinP
flow (2<.grpc.gateway.protoc_gen_swagger.options.SecurityScheme.FlowRflow+
authorization_url (	RauthorizationUrl
	token_url (	RtokenUrlG
scopes (2/.grpc.gateway.protoc_gen_swagger.options.ScopesRscopes"K
Type
TYPE_INVALID 

TYPE_BASIC
TYPE_API_KEY
TYPE_OAUTH2"1
In

IN_INVALID 
IN_QUERY
	IN_HEADER"j
Flow
FLOW_INVALID 
FLOW_IMPLICIT
FLOW_PASSWORD
FLOW_APPLICATION
FLOW_ACCESS_CODE"�
SecurityRequirement�
security_requirement (2U.grpc.gateway.protoc_gen_swagger.options.SecurityRequirement.SecurityRequirementEntryRsecurityRequirement0
SecurityRequirementValue
scope (	Rscope�
SecurityRequirementEntry
key (	Rkeyk
value (2U.grpc.gateway.protoc_gen_swagger.options.SecurityRequirement.SecurityRequirementValueRvalue:8"�
ScopesP
scope (2:.grpc.gateway.protoc_gen_swagger.options.Scopes.ScopeEntryRscope8

ScopeEntry
key (	Rkey
value (	Rvalue:8BCZAgithub.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger/optionsJ�
  �

  

/

 X
	
 X
	
 "
�
  )� `Swagger` is a representation of OpenAPI v2 specification's Swagger object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#swaggerObject

 TODO(ivucica): document fields



 

  

  

  

  	

  

 

 

 

 

 

 

 

 

 	

 

 

 

 

 	

 

  

  

   

   

   

  

  

  

  

  	

  

  

  

  	


  

  

  


 %

 


 

  

 #$

 

 


 

 

 

 

 


 

 

 
.
 	" field 8 is reserved for 'paths'.


 	 

 	 

 	 
�
 	 w field 9 is reserved for 'definitions', which at this time are already
 exposed as and customizable as proto messages.


 	 

 	 

 	 

 !'

 ! 

 !

 !!

 !$&

 "0

 "!'

 "

 "*

 "-/

 	#-

 	#


 	#

 	#'

 	#*,
�
 	'� field 13 is reserved for 'tags', which are supposed to be exposed as and
 customizable as proto services. TODO(ivucica): add processing of proto
 service objects into OpenAPI v2 Tag objects.


 	'

 	'

 	'

 
(+

 
('

 
(

 
(%

 
((*
�
0 >� `Operation` is a representation of OpenAPI v2 specification's Operation object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#operationObject

 TODO(ivucica): document fields



0

 1

 1


 1

 1

 1

2

21

2

2	

2

3

32

3

3	

3

4*

43

4

4%

4()

5

54*

5

5	

5

6

6


6

6

6

7

7


7

7

7
3
	9' field 8 is reserved for 'parameters'.


	 9

	 9

	 9

:&

:9

:

:!

:$%

;

;


;

;

;

	<

	<;

	<

	<

	<


=-


=



=


='


=*,
�
D O� `Response` is a representation of OpenAPI v2 specification's Response object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#responseObject




D
z
 Gm `Description` is a short description of the response.
 GFM syntax can be used for rich text representation.


 GD

 G

 G	

 G
�
J� `Schema` optionally defines the structure of the response.
 If `Schema` is not provided, it means there is no content to the response.


JG

J

J	

J
0
	L$ field 3 is reserved for 'headers'.


	 L

	 L

	 L
0
	N$ field 3 is reserved for 'example'.


	N

	N

	N
�
V ]� `Info` is a representation of OpenAPI v2 specification's Info object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#infoObject

 TODO(ivucica): document fields



V

 W

 WV

 W

 W	

 W

X

XW

X

X	

X

Y

YX

Y

Y	

Y

Z

ZY

Z	

Z


Z

[

[Z

[	

[


[

\

\[

\

\	

\
�
d h� `Contact` is a representation of OpenAPI v2 specification's Contact object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#contactObject

 TODO(ivucica): document fields



d

 e

 ed

 e

 e	

 e

f

fe

f

f	

f

g

gf

g

g	

g
�
n s� `License` is a representation of OpenAPI v2 specification's License object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#licenseObject




n
;
 p. Required. The license name used for the API.


 pn

 p

 p	

 p
5
r( A URL to the license used for the API.


rp

r

r	

r
�
{ ~� `ExternalDocumentation` is a representation of OpenAPI v2 specification's
 ExternalDocumentation object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#externalDocumentationObject

 TODO(ivucica): document fields



{

 |

 |{

 |

 |	

 |

}

}|

}

}	

}
�
� �� `Schema` is a representation of OpenAPI v2 specification's Schema object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#schemaObject

 TODO(ivucica): document fields


�

 �

 ��

 �

 �

 �

�

��

�

�	

�

�

��

�

�

�
-
	�  field 4 is reserved for 'xml'.


	 �

	 �

	 �

�*

��

�

�%

�()

�"

��*

�

�

� !
�
� �� `JSONSchema` represents properties from JSON Schema taken, and as used, in
 the OpenAPI v2 spec.

 This includes changes made by OpenAPI v2.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#schemaObject

 See also: https://cswr.github.io/JsonSchema/spec/basic_types/,
 https://github.com/json-schema-org/json-schema-spec/blob/master/schema.json

 TODO(ivucica): document fields


�
F
	�9 field 1 is reserved for '$id', omitted from OpenAPI v2.


	 �

	 �

	 �
J
	�= field 2 is reserved for '$schema', omitted from OpenAPI v2.


	�

	�

	�
�
 �� Ref is used to define an external reference to include in the message.
 This could be a fully qualified proto message reference, and that type must be imported
 into the protofile. If no message is identified, the Ref will be used verbatim in
 the output.
 For example:
  `ref: ".google.protobuf.Timestamp"`.


 ��

 �

 �	

 �
K
	�> field 4 is reserved for '$comment', omitted from OpenAPI v2.


	�

	�

	�

�

��

�

�	

�

�

��

�

�	

�

�

��

�

�	

�
q
	�d field 8 is reserved for 'readOnly', which has an OpenAPI v2-specific meaning and is defined there.


	�

	�

	�
p
	�c field 9 is reserved for 'examples', which is omitted from OpenAPI v2 in favor of 'example' field.


	�

	�

	�

�

��

�

�	

�

�

��

�

�	

�

�

��

�

�

�

�

��

�

�	

�

�

��

�

�

�

	�

	��

	�

	�	

	�


�


��


�


�	


�

�

��

�

�	

�
S
	�F field 18 is reserved for 'additionalItems', omitted from OpenAPI v2.


	�

	�

	�
i
	�\ field 19 is reserved for 'items', but in OpenAPI-specific way. TODO(ivucica): add 'items'?


	�

	�

	�

�

��

�

�	

�

�

��

�

�	

�

�

��

�

�

�
L
	�? field 23 is reserved for 'contains', omitted from OpenAPI v2.


	�

	�

	�

�

��

�

�	

�

�

��

�

�	

�

� 

�


�

�

�
�
	�z field 27 is reserved for 'additionalProperties', but in OpenAPI-specific way. TODO(ivucica): add 'additionalProperties'?


	�

	�

	�
O
	�B field 28 is reserved for 'definitions', omitted from OpenAPI v2.


		�

		�

		�
}
	�p field 29 is reserved for 'properties', but in OpenAPI-specific way. TODO(ivucica): add 'additionalProperties'?


	
�

	
�

	
�
�
	�� following fields are reserved, as the properties have been omitted from OpenAPI v2:
 patternProperties, dependencies, propertyNames, const


	�

	�

	�
0
�" Items in 'array' must be unique.


�


�

�

�

 ��

 �

  �

  �

  �

 �

 �	

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �

 �


 �

 �

 �


 �

 �

 �


 �

�+

�


� 

�!%

�(*
�
	�� following fields are reserved, as the properties have been omitted from OpenAPI v2:
 format, contentMediaType, contentEncoding, if, then, else


	�

	�

	�
i
	�\ field 42 is reserved for 'allOf', but in OpenAPI-specific way. TODO(ivucica): add 'allOf'?


	�

	�

	�
u
	�h following fields are reserved, as the properties have been omitted from OpenAPI v2:
 anyOf, oneOf, not


	�

	�

	�
�
	� �� `Tag` is a representation of OpenAPI v2 specification's Tag object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#tagObject

 TODO(ivucica): document fields


	�
�
		�� field 1 is reserved for 'name'. In our generator, this is (to be) extracted
 from the name of proto service, and thus not exposed to the user, as
 changing tag object's name would break the link to the references to the
 tag in individual operation specifications.

 TODO(ivucica): Add 'name' property. Use it to allow override of the name of
 global Tag object, then use that name to reference the tag throughout the
 Swagger file.


		 �

		 �

		 �
j
	 �\ TODO(ivucica): Description should be extracted from comments on the proto
 service object.


	 ��

	 �

	 �	

	 �

	�*

	��

	�

	�%

	�()
�

� �� `SecurityDefinitions` is a representation of OpenAPI v2 specification's
 Security Definitions object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#securityDefinitionsObject

 A declaration of the security schemes available to be used in the
 specification. This does not enforce the security schemes on the operations
 and only serves to provide the relevant details for each scheme.



�
_

 �+Q A single security scheme definition, mapping a "name" to the scheme it defines.



 ��


 �


 �&


 �)*
�
� �� `SecurityScheme` is a representation of OpenAPI v2 specification's
 Security Scheme object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#securitySchemeObject

 Allows the definition of a security scheme that can be used by the
 operations. Supported schemes are basic authentication, an API key (either as
 a header or as a query parameter) and OAuth2's common flows (implicit,
 password, application and access code).


�
m
 ��] Required. The type of the security scheme. Valid values are "basic",
 "apiKey" or "oauth2".


 �

  �

  �

  �

 �

 �

 �

 �

 �

 �

 �

 �

 �
^
��N Required. The location of the API key. Valid values are "query" or "header".


�	

 �

 �

 �

�

�

�

�

�

�
�
��� Required. The flow used by the OAuth2 security scheme. Valid values are
 "implicit", "password", "application" or "accessCode".


�

 �

 �

 �

�

�

�

�

�

�

�

�

�

�

�

�
k
 �] Required. The type of the security scheme. Valid values are "basic",
 "apiKey" or "oauth2".


 ��

 �

 �

 �
8
�* A short description for security scheme.


��

�

�	

�
c
�U Required. The name of the header or query parameter to be used.

 Valid for apiKey.


��

�

�	

�
p
�b Required. The location of the API key. Valid values are "query" or "header".

 Valid for apiKey.


��

�

�

�

�
�� Required. The flow used by the OAuth2 security scheme. Valid values are
 "implicit", "password", "application" or "accessCode".

 Valid for oauth2.


��

�

�

�
�
�� Required. The authorization URL to be used for this flow. This SHOULD be in
 the form of a URL.

 Valid for oauth2/implicit and oauth2/accessCode.


��

�

�	

�
�
�� Required. The token URL to be used for this flow. This SHOULD be in the
 form of a URL.

 Valid for oauth2/password, oauth2/application and oauth2/accessCode.


��

�

�	

�
b
�T Required. The available scopes for the OAuth2 security scheme.

 Valid for oauth2.


��

�

�	

�
�
� �� `SecurityRequirement` is a representation of OpenAPI v2 specification's
 Security Requirement object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#securityRequirementObject

 Lists the required security schemes to execute this operation. The object can
 have multiple security schemes declared in it which are all required (that
 is, there is a logical AND between the schemes).

 The name used for each property MUST correspond to a security scheme
 declared in the Security Definitions.


�
�
 ��� If the security scheme is of type "oauth2", then the value is a list of
 scope names required for the execution. For other security scheme types,
 the array MUST be empty.


 �
"

  �

  �

  �

  �

  �
�
 �A� Each name must correspond to a security scheme which is declared in
 the Security Definitions. If the security scheme is of type "oauth2",
 then the value is a list of scope names required for the execution.
 For other security scheme types, the array MUST be empty.


 ��

 �'

 �(<

 �?@
�
� �� `Scopes` is a representation of OpenAPI v2 specification's Scopes object.

 See: https://github.com/OAI/OpenAPI-Specification/blob/3.0.0/versions/2.0.md#scopesObject

 Lists the available scopes for an OAuth2 security scheme.


�
l
 � ^ Maps between a name of a scope to a short description of it (as the value
 of the property).


 ��

 �

 �

 �bproto3
�
,protoc-gen-swagger/options/annotations.proto'grpc.gateway.protoc_gen_swagger.options*protoc-gen-swagger/options/openapiv2.proto google/protobuf/descriptor.proto:|
openapiv2_swagger.google.protobuf.FileOptions� (20.grpc.gateway.protoc_gen_swagger.options.SwaggerRopenapiv2Swagger:�
openapiv2_operation.google.protobuf.MethodOptions� (22.grpc.gateway.protoc_gen_swagger.options.OperationRopenapiv2Operation:|
openapiv2_schema.google.protobuf.MessageOptions� (2/.grpc.gateway.protoc_gen_swagger.options.SchemaRopenapiv2Schema:s
openapiv2_tag.google.protobuf.ServiceOptions� (2,.grpc.gateway.protoc_gen_swagger.options.TagRopenapiv2Tag:|
openapiv2_field.google.protobuf.FieldOptions� (23.grpc.gateway.protoc_gen_swagger.options.JSONSchemaRopenapiv2FieldBCZAgithub.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger/optionsJ�
  +

  

/

 X
	
 X
	
 3
	
)
	
	 
�
 #� ID assigned by protobuf-global-extension-registry@google.com for grpc-gateway project.

 All IDs are the same, as assigned. It is okay that they are the same, as they extend
 different descriptor messages.



 	"

 	$


 	


 



 "
	
 
�
'� ID assigned by protobuf-global-extension-registry@google.com for grpc-gateway project.

 All IDs are the same, as assigned. It is okay that they are the same, as they extend
 different descriptor messages.



$

&








"&
	
 
�
!� ID assigned by protobuf-global-extension-registry@google.com for grpc-gateway project.

 All IDs are the same, as assigned. It is okay that they are the same, as they extend
 different descriptor messages.



%

'





	


 
	
 $
�
#� ID assigned by protobuf-global-extension-registry@google.com for grpc-gateway project.

 All IDs are the same, as assigned. It is okay that they are the same, as they extend
 different descriptor messages.



%

#'


#


#


#
	
% +
�
*$� ID assigned by protobuf-global-extension-registry@google.com for grpc-gateway project.

 All IDs are the same, as assigned. It is okay that they are the same, as they extend
 different descriptor messages.



%#

*%%


*


*


*#bproto3
�
common.proto	coolstoregoogle/api/annotations.proto,protoc-gen-swagger/options/annotations.protoB��A��
Coolstore services"y
coolstore-microservices project7https://github.com/vietnam-devs/coolstore-microservicesthangchung.onthenet@gmail.com21.0Z�
�
OAuth2�(2'http://localhost:5001/connect/authorize:#http://localhost:5001/connect/tokenB�
.
inventory_api_scopeGrants inventory access
$
cart_api_scopeGrants cart access
*
pricing_api_scopeGrants pricing access
(
review_api_scopeGrants review access
*
catalog_api_scopeGrants catalog access
(
rating_api_scopeGrants rating accessJJ
  5

  


	
 %
	
5
	
 5

� 5bproto3
�
google/protobuf/empty.protogoogle.protobuf"
EmptyBv
com.google.protobufB
EmptyProtoPZ'github.com/golang/protobuf/ptypes/empty��GPB�Google.Protobuf.WellKnownTypesJ�
 3
�
 2� Protocol Buffers - Google's data interchange format
 Copyright 2008 Google Inc.  All rights reserved.
 https://developers.google.com/protocol-buffers/

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

     * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above
 copyright notice, this list of conditions and the following disclaimer
 in the documentation and/or other materials provided with the
 distribution.
     * Neither the name of Google Inc. nor the names of its
 contributors may be used to endorse or promote products derived from
 this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


 

" ;
	
%" ;

# >
	
# >

$ ,
	
$ ,

% +
	
% +

& "
	

& "

' !
	
$' !

( 
	
( 
�
 3 � A generic empty message that you can re-use to avoid defining duplicated
 empty messages in your APIs. A typical example is to use it as the request
 or the response type of an API method. For instance:

     service Foo {
       rpc Bar(google.protobuf.Empty) returns (google.protobuf.Empty);
     }

 The JSON representation for `Empty` is empty JSON object `{}`.



 3bproto3
�
inventory.proto	coolstoregoogle/api/annotations.protogoogle/protobuf/empty.proto"j
InventoryDto
id (	Rid
location (	Rlocation
quantity (Rquantity
link (	Rlink"S
GetInventoriesResponse9
inventories (2.coolstore.InventoryDtoRinventories"%
GetInventoryRequest
id (	Rid"G
GetInventoryResponse/
result (2.coolstore.InventoryDtoRresult"%
DbMigrationResponse
ok (Rok2�
InventoryServicer
GetInventories.google.protobuf.Empty!.coolstore.GetInventoriesResponse"%���/inventory/api/availabilities{
GetInventory.coolstore.GetInventoryRequest.coolstore.GetInventoryResponse"*���$"/inventory/api/availabilities/{id}r
DbMigration.google.protobuf.Empty.coolstore.DbMigrationResponse"+���%" /inventory/api/inventory/migrate:*B+�(VND.CoolStore.Services.Inventory.v1.GrpcJ�
  /

  



 E
	
% E
	
 %
	
$


  


 

  

  

  *

  5K

  	

	  �ʼ"	

 

 

 &

 1E

 

	 �ʼ"

 

 

 '

 2E

 

	 �ʼ"


  


 

  

  

  

  	

  

 

 

 

 	

 

 

 

 

 

 

 

 

 

 	

 


! #


!

 "(

 "


 "

 "#

 "&'


% '


%

 &

 &%

 &

 &	

 &


) +


)

 *

 *)

 *

 *

 *


- /


-

 .

 .-

 .

 .	

 .bproto3
�
rating.proto	coolstoregoogle/api/annotations.protogoogle/protobuf/empty.proto"g
	RatingDto
id (	Rid

product_id (	R	productId
user_id (	RuserId
cost (Rcost"D
GetRatingsResponse.
ratings (2.coolstore.RatingDtoRratings"<
GetRatingByProductIdRequest

product_id (	R	productId"L
GetRatingByProductIdResponse,
rating (2.coolstore.RatingDtoRrating"a
CreateRatingRequest

product_id (	R	productId
user_id (	RuserId
cost (Rcost"D
CreateRatingResponse,
rating (2.coolstore.RatingDtoRrating"q
UpdateRatingRequest
id (	Rid

product_id (	R	productId
user_id (	RuserId
cost (Rcost"D
UpdateRatingResponse,
rating (2.coolstore.RatingDtoRrating2�
RatingService`

GetRatings.google.protobuf.Empty.coolstore.GetRatingsResponse"���/rating/api/ratings�
GetRatingByProductId&.coolstore.GetRatingByProductIdRequest'.coolstore.GetRatingByProductIdResponse"(���" /rating/api/ratings/{product_id}o
CreateRating.coolstore.CreateRatingRequest.coolstore.CreateRatingResponse"���"/rating/api/ratings:*o
UpdateRating.coolstore.UpdateRatingRequest.coolstore.UpdateRatingResponse"���/rating/api/ratings:*B(�%VND.CoolStore.Services.Rating.v1.GrpcJ�
  F

  



 B
	
% B
	
 %
	
$


  


 

  

  

  &

  1C

  	

	  �ʼ"	

 

 

 6

 A]

 

	 �ʼ"

 

 

 &

 1E

 

	 �ʼ"

 

 

 &

 1E

 

	 �ʼ"


   %


  

  !

  ! 

  !

  !	

  !

 "

 "!

 "

 "	

 "

 #

 #"

 #

 #	

 #

 $

 $#

 $

 $	

 $


' )


'

 (!

 (


 (

 (

 ( 


+ -


+#

 ,

 ,+%

 ,

 ,	

 ,


/ 1


/$

 0

 0/&

 0

 0

 0


3 7


3

 4

 43

 4

 4	

 4

5

54

5

5	

5

6

65

6

6	

6


9 ;


9

 :

 :9

 :

 :

 :


= B


=

 >

 >=

 >

 >	

 >

?

?>

?

?	

?

@

@?

@

@	

@

A

A@

A

A	

A


D F


D

 E

 ED

 E

 E

 Ebproto3
�
review.proto	coolstoregoogle/api/annotations.protogoogle/protobuf/empty.proto"�
	ReviewDto
id (	Rid
content (	Rcontent
	author_id (	RauthorId
author_name (	R
authorName

product_id (	R	productId!
product_name (	RproductName"8
	AuthorDto
id (	Rid
	user_name (	RuserName"(
PingResponse
message (	Rmessage"2
GetReviewsRequest

product_id (	R	productId"D
GetReviewsResponse.
reviews (2.coolstore.ReviewDtoRreviews"g
CreateReviewRequest

product_id (	R	productId
user_id (	RuserId
content (	Rcontent"D
CreateReviewResponse,
result (2.coolstore.ReviewDtoRresult"2
DeleteReviewRequest
	review_id (	RreviewId"&
DeleteReviewResponse
id (	Rid"J
EditReviewRequest
	review_id (	RreviewId
content (	Rcontent"B
EditReviewResponse,
result (2.coolstore.ReviewDtoRresult2\
PingServiceM
Ping.google.protobuf.Empty.coolstore.PingResponse"���/review/ping2�
ReviewServices

GetReviews.coolstore.GetReviewsRequest.coolstore.GetReviewsResponse"(���" /review/api/reviews/{product_id}o
CreateReview.coolstore.CreateReviewRequest.coolstore.CreateReviewResponse"���"/review/api/reviews:*|

EditReview.coolstore.EditReviewRequest.coolstore.EditReviewResponse"1���+)/review/api/reviews/{review_id}/{content}x
DeleteReview.coolstore.DeleteReviewRequest.coolstore.DeleteReviewResponse"'���!*/review/api/reviews/{review_id}B(�%VND.CoolStore.Services.Review.v1.GrpcJ�
  a

  



 B
	
% B
	
 %
	
$


  


 

  

  


   

  +7

  	

	  �ʼ"	


 %




 

 

 "

 -?

 

	 �ʼ"





&

1E



	�ʼ"





"

-?



	�ʼ"

 $

 

 &

 1E

!#

	�ʼ"!#


 ' .


 '

  (

  ('

  (

  (	

  (

 )

 )(

 )

 )	

 )

 *

 *)

 *

 *	

 *

 +

 +*

 +

 +	

 +

 ,

 ,+

 ,

 ,	

 ,

 -

 -,

 -

 -	

 -
e
7 :2Ymessage ProductDto {
string id = 1;
string name = 2;
string desc = 3;
double price = 4;
}


7

 8

 87

 8

 8	

 8

9

98

9

9	

9


< >


<

 =

 =<

 =

 =	

 =


@ B


@

 A

 A@

 A

 A	

 A


D F


D

 E!

 E


 E

 E

 E 


H L


H

 I

 IH

 I

 I	

 I

J

JI

J

J	

J

K

KJ

K

K	

K


N P


N

 O

 ON

 O

 O

 O


R T


R

 S

 SR

 S

 S	

 S


V X


V

 W

 WV

 W

 W	

 W


	Z ]


	Z

	 [

	 [Z

	 [

	 [	

	 [

	\

	\[

	\

	\	

	\



_ a



_


 `


 `_


 `


 `


 `bproto3