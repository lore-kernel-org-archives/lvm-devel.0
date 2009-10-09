From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 09 Oct 2009 14:47:42 +0200
Subject: [PATCH 01/13] Replicator: export out_ function for modules
In-Reply-To: <4ACDC6AD.2090207@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>	<20091007150503.GC3054@agk-dp.fab.redhat.com>
	<4ACDC6AD.2090207@redhat.com>
Message-ID: <4ACF30EE.9000901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 8.10.2009 13:02, Zdenek Kabelac napsal(a):
> Dne 7.10.2009 17:05, Alasdair G Kergon napsal(a):
>> On Mon, Oct 05, 2009 at 04:00:28PM +0200, Zdenek Kabelac wrote:
>>> +/* insert new line */
>>> +int out_newline(struct formatter *f)
>>> +{
>>> +	outnl(f);
>>> +	return 0;
>>
>> Should return 1 here, and the caller has to check that.
> 
> true
> 
>> Instead, I think the outnl macro should be changed to work like the outf one.
>> (make the 'f->nl' part internal to an export.c function instead of the header file)
>> The idea was that the callers would be using this so frequently, it was
>> clearer just writing 'outf(...)'  than 'if (!out_text(...)) return_0;' everywhere.
>>
>> Alasdair
>>
> 
> So how about this:
> 
> +/* insert new line */
> +int out_newline(struct formatter *f)
> +{
> +	return f->nl(f);
> +}
> +
> 
> I think this will be the easiest way - nl() is virtual function thus it can't
> be easily 'macro-ised'.
> 

Hmm I've maybe slightly misunderstood your comment.
So would you agree with following extension:

-#define outnl(f) do {if (!f->nl(f)) return_0;} while (0)
+#define outnl(f) do {if (!out_newline(f)) return_0;} while (0)

Thus the internal code would be also using out_newline()  just like
outf() is using out_text()?

Eventually we may keep  outnl() as is - and introduce outnewl for externs.
+#define outnewl(f) do {if (!out_newline(f)) return_0;} while (0)

Zdenek


