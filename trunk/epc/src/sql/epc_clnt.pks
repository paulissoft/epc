--$NO_KEYWORD_EXPANSION$
/*
REMARK
REMARK  $Header$
REMARK
REMARK  Description:    Oracle package specification for External Procedure Call Toolkit.
REMARK
REMARK  $Log$
REMARK  Revision 1.12  2005/01/03 12:59:04  gpaulissen
REMARK  Release 4.4.0
REMARK
REMARK  Revision 1.11  2005/01/03 12:56:27  gpaulissen
REMARK  Release 4.4.0
REMARK
REMARK  Revision 1.10  2004/12/28 12:18:11  gpaulissen
REMARK  Test on Amazon
REMARK
REMARK  Revision 1.9  2004/12/16 18:43:08  gpaulissen
REMARK  generated HTML added
REMARK
REMARK  Revision 1.8  2004/12/16 17:50:31  gpaulissen
REMARK  REMARK blocks commented for PLDoc
REMARK
REMARK  Revision 1.7  2004/12/16 16:03:24  gpaulissen
REMARK  Web services added
REMARK
REMARK  Revision 1.6  2004/10/20 20:38:44  gpaulissen
REMARK  make lint
REMARK
REMARK  Revision 1.5  2004/10/15 13:53:40  gpaulissen
REMARK  XML added
REMARK
REMARK  Revision 1.4  2004/05/21 15:04:34  gpaulissen
REMARK  Eerste implementatie
REMARK
REMARK  Revision 1.3  2004/04/21 11:16:56  gpaulissen
REMARK  .
REMARK
REMARK  Revision 1.2  2004/04/05 14:52:33  gpaulissen
REMARK  Interface changed
REMARK
REMARK  Revision 1.1  2004/04/02 10:26:28  gpaulissen
REMARK  New interface for epc
REMARK
REMARK
REMARK
*/

create or replace package epc_clnt is
/**
--
-- This package is used to implement the client side of RPC like functionality
-- on an Oracle database.
-- Messages are sent by the client to a server. The transport mechanisms
-- supported are database pipes (DBMS_PIPE), HTTP (UTL_HTTP) and TCP/IP (UTL_TCP).
--
-- The flow of procedure calls will typically look like this:<br />
-- 1) Set connection information.<br />
--    a) epc_clnt.register<br />
--    b) epc_clnt.get_epc_clnt_object<br />
--    c) epc_clnt.set_protocol (optional, the default is NATIVE)<br />
--    d) epc_clnt.set_connection_info (optional for database pipes)<br />
--    e) epc_clnt.set_request_send_timeout (optional)<br />
--    f) epc_clnt.set_response_recv_timeout (optional)<br />
--    g) epc_clnt.set_epc_clnt_object<br />
-- 2) Marshall a function call into a message<br />
--    a) epc_clnt.get_epc_clnt_object<br />
--    b) epc_clnt.new_request<br />
--    c) epc_clnt.set_request_parameter (for all IN and IN OUT parameters)<br />
-- 3) Send the message<br />
--    a) epc_clnt.send_request<br />
-- 4) Receive the response<br />
--    a) epc_clnt.recv_response<br />
-- 5) Unmarshall the message<br />
--    a) epc_clnt.get_response_parameter (for all OUT and IN OUT parameters)<br />
-- 6) Save the client info<br/ >
--    a) epc_clnt.set_epc_clnt_object<br />
--
-- @headcom
*/

/* 
   History of protocols:
 
   1 - original protocol
       To server: RESULT PIPE, PROTOCOL, INTERFACE, FUNCTION, PARAMETERS IN
       From server: EXEC CODE, SQL CODE, PARAMETERS OUT

   2 - same as protocol 1, but FUNCTION is now the FUNCTION SIGNATURE.

   3 - To server: PROTOCOL, MSG SEQ, INTERFACE, FUNCTION, [ RESULT PIPE, ] PARAMETERS IN
       From server: MSG SEQ, PARAMETERS OUT

       MSG SEQ has been added in order to check for messages which have
       not been (correctly) processed by the server. 

   4 - To server: PROTOCOL, MSG SEQ, INTERFACE, FUNCTION, RESULT PIPE, PARAMETERS IN
       From server: MSG SEQ, PARAMETERS OUT

       GJP 07-04-2004
       RESULT PIPE is 'N/A' for oneway functions.

   5 - To server: PROTOCOL, MSG SEQ, SOAP REQUEST MESSAGE [, RESULT PIPE ]
       From server: MSG SEQ, SOAP RESPONSE MESSAGE

       GJP 21-10-2004
       RESULT PIPE is empty for oneway functions.

   6 - To server: PROTOCOL, MSG SEQ, XMLRPC REQUEST MESSAGE [, RESULT PIPE ]
       From server: MSG SEQ, XMLRPC RESPONSE MESSAGE

       GJP 24-07-2007

   7 - To server: PROTOCOL, MSG SEQ, NATIVE REQUEST MESSAGE [, RESULT PIPE ]
       From server: MSG SEQ, NATIVE RESPONSE MESSAGE

       The request message consists of INTERFACE, FUNCTION and PARAMETERS IN.

       The response message consists of ERROR CODE and PARAMETERS OUT.

       Each message argument is encoded as follows:
       a) data type (epc.data_type_subtype as a 1 byte character)
       b) data length (for string and xml a 4 byte hexadecimal string and for others a 2 byte hexadecimal string)
       c) the data as a string
*/

subtype protocol_subtype is pls_integer;

"SOAP" constant protocol_subtype := 5; -- default protocol for HTTP
"XMLRPC" constant protocol_subtype := 6; -- default protocol for TCP/IP
"NATIVE" constant protocol_subtype := 7; -- default protocol for DBMS_PIPE

type http_connection_rectype is record (
  url varchar2(4000) /* http://... */
, method varchar2(10) default 'POST'
, version varchar2(10) default utl_http.http_version_1_1
);

subtype http_connection_subtype is http_connection_rectype;

subtype connection_method_subtype is pls_integer;

CONNECTION_METHOD_DBMS_PIPE constant connection_method_subtype := 1;
CONNECTION_METHOD_UTL_TCP constant connection_method_subtype := 2;
CONNECTION_METHOD_UTL_HTTP constant connection_method_subtype := 3;

/**
-- Register an interface
--
-- @param p_interface_name  The name of the interface to register.
--
*/
procedure register
( p_interface_name in epc.interface_name_subtype
);

/**
-- Get the connection information of an already registered interface.
--
-- @param p_interface_name  The name of the interface.
-- @param p_epc_clnt_object   Epc client info
--
-- @throws no_data_found  Not registered yet.
*/
procedure get_epc_clnt_object
( p_epc_clnt_object out nocopy epc_clnt_object
, p_interface_name in epc.interface_name_subtype
);

/**
-- Set the connection information of an already registered interface.
--
-- @param p_epc_clnt_object   Epc client info
-- @param p_interface_name  The name of the interface.
--
-- @throws no_data_found  Not registered yet.
*/
procedure set_epc_clnt_object
( p_epc_clnt_object in epc_clnt_object
, p_interface_name in epc.interface_name_subtype
);

/* 
|| Protocol related functions/procedures.
*/

/**
-- Set the protocol for later use.
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_protocol       The protocol
--
-- @throws value_error  When the protocol is not NATIVE, SOAP nor XMLRPC.
*/
procedure set_protocol
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_protocol in protocol_subtype
);

/**
-- Get the protocol. 
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_protocol       The protocol
*/
procedure get_protocol
( p_epc_clnt_object in epc_clnt_object
, p_protocol out protocol_subtype
);

/* 
|| Connection related functions/procedures.
*/

/**
-- Set the connection info for HTTP.
--
-- Set the connection method to HTTP and store the HTTP connection info for
-- later use. The protocol will be set to SOAP.
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_connection     The HTTP connection info.
*/
procedure set_connection_info
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_connection in http_connection_subtype
);

/**
-- Get the HTTP connection info. 
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_connection     The HTTP connection info
--
-- @throws no_data_found  connection method is not utl_http
*/
procedure get_connection_info
( p_epc_clnt_object in epc_clnt_object
, p_connection out nocopy http_connection_subtype
);

/**
-- Set the connection info for TCP/IP.
--
-- Set the connection method to TCP/IP and store the open TCP/IP connection for
-- later use. The EPC will not open or close the TCP/IP connection. It is the
-- responsability of the client program to open and close the connection. The
-- protocol will be set to XMLRPC.
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_connection     An open TCP/IP connection (see utl_tcp.open_connection)
*/
procedure set_connection_info
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_connection in utl_tcp.connection
);

/**
-- Get the TCP/IP connection info. 
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_connection     An open TCP/IP connection
--                         (see utl_tcp.open_connection)
--
-- @throws no_data_found  connection method is not utl_tcp
*/
procedure get_connection_info
( p_epc_clnt_object in epc_clnt_object
, p_connection out nocopy utl_tcp.connection
);

/**
-- Set the connection info for database pipes.
--
-- Set the connection type to database pipes and store the pipe name for
-- later use. Each interface may have a different connection. The
-- protocol will be set to NATIVE.
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_pipe_name      The request pipe name
*/
procedure set_connection_info
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_pipe_name in epc.pipe_name_subtype
);

/**
-- Get the database request pipe.
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_pipe_name      The request pipe name
--
-- @throws no_data_found  connection method is not dbms_pipe
*/
procedure get_connection_info
( p_epc_clnt_object in epc_clnt_object
, p_pipe_name out epc.pipe_name_subtype
);

/**
-- Set the request send timeout.
-- 
-- @param p_epc_clnt_object         Epc client info
-- @param p_request_send_timeout  The request send timeout
*/
procedure set_request_send_timeout
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_request_send_timeout in pls_integer
);

/**
-- Set the response receive timeout.
-- 
-- @param p_epc_clnt_object          Epc client info
-- @param p_response_recv_timeout  The response receive timeout
*/
procedure set_response_recv_timeout
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_response_recv_timeout in pls_integer
);

/**
-- Set the namespace.
--
-- The namespace for an interface is initially equal to the interface name.
-- For Web services this may need to be overridden.
-- The namespace is added as an attribute to the method element, e.g.
-- &lt;METHOD xmlns="NAMESPACE"&gt;
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_namespace      The new namespace
*/
procedure set_namespace
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_namespace in varchar2
);

/**
-- Set the inline namespace.
--
-- The inline namespace for an interface is the prefix for the method name.
-- The default inline namespace is ns1. For Web services this may need to be
-- overridden.  The namespace is added as an attribute to the method element,
-- e.g. &lt;INLINE_NAMESPACE:METHOD xmlns:INLINE_NAMESPACE="NAMESPACE"&gt;
-- 
-- @param p_epc_clnt_object     Epc client info
-- @param p_inline_namespace  The new inline namespace
*/
procedure set_inline_namespace
( p_epc_clnt_object in out nocopy epc_clnt_object
, p_inline_namespace in varchar2
);

/**
-- Start a new request.
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_method_name    The method name
-- @param p_oneway         Is the procedure call a oneway call,
                           i.e. do we NOT wait for a response? 
                           0 means we will wait for a response.
*/
procedure new_request
( p_epc_clnt_object in epc_clnt_object
, p_method_name in epc.method_name_subtype
, p_oneway in pls_integer
);

/**
-- Set a request parameter (IN or IN OUT).
-- 
-- @param p_epc_clnt_object  Epc client info
-- @param p_name           The name of the parameter
-- @param p_data_type      The data type (should be epc.data_type_string)
-- @param p_value          The value of the parameter
-- @param p_max_bytes      The maximum length of p_value in bytes (if non-null)
--
-- @throws epc.e_illegal_null_value  p_value is NULL
-- @throws value_error               data type is incorrect or maximum length reached
*/
procedure set_request_parameter
( p_epc_clnt_object in epc_clnt_object
, p_name in epc.parameter_name_subtype
, p_data_type in epc.data_type_subtype
, p_value in varchar2
, p_max_bytes in integer default null
);

procedure set_request_parameter
( p_epc_clnt_object in epc_clnt_object
, p_name in epc.parameter_name_subtype
, p_data_type in epc.data_type_subtype
, p_value in number
);

procedure set_request_parameter
( p_epc_clnt_object in epc_clnt_object
, p_name in epc.parameter_name_subtype
, p_data_type in epc.data_type_subtype
, p_value in date
);

/**
-- Send a request.
-- 
-- @param p_epc_clnt_object  Epc client info
--
-- @throws epc.e_comm_error  Error while sending the message
-- @throws program_error     Protocol and connection method do not match
*/
procedure send_request
( p_epc_clnt_object in out nocopy epc_clnt_object
);

/**
-- Receive a response.
-- 
-- @param p_epc_clnt_object  Epc client info
--
-- @throws epc.e_comm_error      Error while sending the message
-- @throws epc.e_wrong_protocol  Message number sent and received do not match
-- @throws program_error         Protocol and connection method do not match
*/
procedure recv_response
( p_epc_clnt_object in out nocopy epc_clnt_object
);

/**
-- Get a response parameter (OUT or IN OUT).
-- 
-- @param p_epc_clnt_object   Epc client info
-- @param p_name            The name of the parameter
-- @param p_data_type       The data type (should be epc.data_type_string)
-- @param p_value           The value of the parameter
-- @param p_max_bytes       The maximum length of p_value in bytes (if non-null)
--
-- @throws value_error    invalid datatype or or maximum length reached
-- @throws ORA-6559       wrong data type requested
-- @throws program_error  Protocol and connection method do not match
*/
procedure get_response_parameter
( p_epc_clnt_object in epc_clnt_object
, p_name in epc.parameter_name_subtype
, p_data_type in epc.data_type_subtype
, p_value out varchar2
, p_max_bytes in integer default null
);

procedure get_response_parameter
( p_epc_clnt_object in epc_clnt_object
, p_name in epc.parameter_name_subtype
, p_data_type in epc.data_type_subtype
, p_value out number
);

procedure get_response_parameter
( p_epc_clnt_object in epc_clnt_object
, p_name in epc.parameter_name_subtype
, p_data_type in epc.data_type_subtype
, p_value out date
);

/**
-- Shutdown the client.
-- 
-- Cleanup all resources, for instance the response pipe.
*/
procedure shutdown;

end epc_clnt;
/

