From: Christine Caulfield <ccaulfie@redhat.com>
Date: Thu, 01 Aug 2013 10:13:31 +0100
Subject: [PATCH RFC] clvmd: verify messages before processing
In-Reply-To: <20130731153111.GB12539@redhat.com>
References: <20130730194649.GA3707@redhat.com> <51F8CBD3.9090201@redhat.com>
	<20130731153111.GB12539@redhat.com>
Message-ID: <51FA26BB.6010105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 31/07/13 16:31, David Teigland wrote:
> On Wed, Jul 31, 2013 at 09:33:23AM +0100, Christine Caulfield wrote:
>>> @@ -2189,10 +2286,22 @@ error:
>>>   void process_message(struct local_client *client, char *buf, int len,
>>>   		     const char *csid)
>>>   {
>>> +	char nodename[max_cluster_member_name_len];
>>>   	struct clvm_header *inheader;
>>> +	int rv;
>>>
>>>   	inheader = (struct clvm_header *) buf;
>>>   	ntoh_clvm(inheader);	/* Byteswap fields */
>>> +
>>> +	rv = verify_message(buf, len);
>>> +	if (rv < 0) {
>>> +		memset(nodename, 0, sizeof(nodename));
>>> +		clops->name_from_csid(csid, nodename);
>>> +		log_error("process_message from %s len %d bad verify\n", nodename, len);
>>> +		dump_message(buf, len);
>>
>> Here you will probably have to return an error to the calling clvmd
>> or you will get delays when the caller times out. If that happens
>> then the 'timed-out' message is less than helpful
>
> The thinking behind no reply was that if a command sends a bogus message,
> it doesn't deserve a reply, and even if it got one, may not handle it
> properly anyway.  So, if we're dealing with a bogus non-message, I think
> we're beyond the point where we can be helpful.  I'm mainly trying to just
> protect clvmd from faulty commands.  But, I looked at how feasible it
> would be, and I don't think it's worth the trouble -- we'd have to do the
> whole add_to_lvmqueue() thing, etc.
>

True it could be awkward and the worst that will happen is a minute's 
delay and an unhelpful message at the other end.

Chrissie


