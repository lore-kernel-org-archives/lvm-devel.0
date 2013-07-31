From: Christine Caulfield <ccaulfie@redhat.com>
Date: Wed, 31 Jul 2013 09:33:23 +0100
Subject: [PATCH RFC] clvmd: verify messages before processing
In-Reply-To: <20130730194649.GA3707@redhat.com>
References: <20130730194649.GA3707@redhat.com>
Message-ID: <51F8CBD3.9090201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 30/07/13 20:46, David Teigland wrote:
> Does this look like it would be useful?  More checks can be
> added over time, but are there any that would be obvious to
> add now?  I'm mainly trying to catch non-message data, and
> not risk rejecting any proper messages.
>

Mostly an ACK but see comment below:

> @@ -2189,10 +2286,22 @@ error:
>   void process_message(struct local_client *client, char *buf, int len,
>   		     const char *csid)
>   {
> +	char nodename[max_cluster_member_name_len];
>   	struct clvm_header *inheader;
> +	int rv;
>
>   	inheader = (struct clvm_header *) buf;
>   	ntoh_clvm(inheader);	/* Byteswap fields */
> +
> +	rv = verify_message(buf, len);
> +	if (rv < 0) {
> +		memset(nodename, 0, sizeof(nodename));
> +		clops->name_from_csid(csid, nodename);
> +		log_error("process_message from %s len %d bad verify\n", nodename, len);
> +		dump_message(buf, len);

Here you will probably have to return an error to the calling clvmd or 
you will get delays when the caller times out. If that happens then the 
'timed-out' message is less than helpful


> +		return;
> +	}
> +
>   	if (inheader->cmd == CLVMD_CMD_REPLY)
>   		process_reply(inheader, len, csid);
>   	else
>


Chrissie


