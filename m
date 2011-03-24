From: Milan Broz <mbroz@redhat.com>
Date: Thu, 24 Mar 2011 13:25:33 +0100
Subject: [PATCH 3/4] Another fix for garbage send in clvmd message
In-Reply-To: <b9919298acd0f83e1cac3a43bd78164f8dece828.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
	<b9919298acd0f83e1cac3a43bd78164f8dece828.1300965223.git.zkabelac@redhat.com>
Message-ID: <4D8B383D.7060003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/24/2011 12:16 PM, Zdenek Kabelac wrote:

> -	_build_header(head, cmd, node, len);
> +	_build_header(head, cmd, node, len - 1);
>  	memcpy(head->node + strlen(head->node) + 1, data, len);
>  
>  	status = _send_request(outbuf, sizeof(struct clvm_header) +
> -			       strlen(head->node) + len, &retbuf, no_response);
> +			       strlen(head->node) + len - 1, &retbuf, no_response);

ACK, but this protocol _MUST_ be rewritten soon completely.

really, no comment to use of this struct...
(note that if strlen(node) > 0, args points somewhere inside on node name. wonderful.

struct clvm_header {
	uint8_t  cmd;	        /* See below */
...
	char node[1];		/* Actually a NUL-terminated string, node name.
				   If this is empty then the command is 
				   forwarded to all cluster nodes unless 
				   FLAG_LOCAL is also set. */
	char args[1];		/* Arguments for the command follow the 
				   node name, This member is only
				   valid if the node name is empty */

Milan


