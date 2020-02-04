/* soapClient.cpp
   Generated by the gSOAP Stub and Skeleton Compiler for C and C++ 2.1.6b
   Copyright (C) 2001-2002 Robert A. van Engelen, Florida State University.
   All rights reserved.
*/
#include "soapH.h"

SOAP_FMAC1 int SOAP_FMAC2 soap_call_ns__getQuote(struct soap *soap, const char *URL, const char *action, char *symbol, float &result)
{
	struct ns__getQuote soap_tmp_ns__getQuote;
	struct ns__getQuoteResponse *soap_tmp_ns__getQuoteResponse;
	soap_tmp_ns__getQuote.symbol=symbol;
	soap_begin(soap);
	soap_serializeheader(soap);
	soap_serialize_ns__getQuote(soap, &soap_tmp_ns__getQuote);
	if (!soap->disable_request_count)
	{	soap_begin_count(soap);
		soap_envelope_begin_out(soap);
		soap_putheader(soap);
		soap_body_begin_out(soap);
		soap_put_ns__getQuote(soap, &soap_tmp_ns__getQuote, "ns:getQuote", "");
		soap_body_end_out(soap);
		soap_envelope_end_out(soap);
	}
	soap_begin_send(soap);
	if (soap_connect(soap, URL, action))
	{
		return soap->error;
	}
	soap_envelope_begin_out(soap);
	soap_putheader(soap);
	soap_body_begin_out(soap);
	soap_put_ns__getQuote(soap, &soap_tmp_ns__getQuote, "ns:getQuote", "");
	soap_body_end_out(soap);
	soap_envelope_end_out(soap);
	soap_putattachments(soap);
	soap_end_send(soap);
	soap_default_float(soap, &result);
	if (soap_begin_recv(soap))
		return soap->error;
	if (soap_envelope_begin_in(soap))
		return soap->error;
	if (soap_recv_header(soap))
		return soap->error;
	if (soap_body_begin_in(soap))
		return soap->error;
	soap_tmp_ns__getQuoteResponse = soap_get_ns__getQuoteResponse(soap, NULL, "ns:getQuoteResponse", "ns:getQuoteResponse");
	if (soap->error){
		if (soap->error == SOAP_TAG_MISMATCH && soap->level == 2)
			soap_recv_fault(soap);
		return soap->error;
	}
	if (soap_body_end_in(soap))
		return soap->error;
	if (soap_envelope_end_in(soap))
		return soap->error;
	if (soap_getattachments(soap))
		return soap->error;
	soap_closesock(soap);
	soap_end_recv(soap);
	result = soap_tmp_ns__getQuoteResponse->result;
	return soap->error;
}

/* end of soapClient.cpp */