From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 31 Jan 2013 15:04:59 -0600
Subject: [PATCH V2 0/2] Add thin lv and thin pool creation support
In-Reply-To: <1359642352-9688-1-git-send-email-mohan@in.ibm.com>
References: <1359642352-9688-1-git-send-email-mohan@in.ibm.com>
Message-ID: <510ADC7B.3090903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/31/2013 08:25 AM, M. Mohan Kumar wrote:
> From: "M. Mohan Kumar" <mohan@in.ibm.com>
> 
> Add thin lv and thin pool creation support to lvm2app.
> 
> Changes from previous version:
> * Add support to specify data block size and low water mark thresold for
> newly created thin pool.
> * Added support for specifying lowwatermark parameter to thin pool
> creation in lvcreate command

OK, so the block size if specified as 0 results in a default value being
selected as before, which is what I believe we want.  The default low
water mark was 0, which is what we believe disables event creation.
This doesn't appear to be a safe default behavior?

One option would be to change the type to a signed integer and change
the meaning from number of blocks free to percentage free and then treat
-1 as pick a sane default.  Thus 0 would be no events and 30 would
indicate when 30% blocks free is remaining to generate an event.  We
could also use an unsigned value and use 100 as please pick a sane
default as this value and values close to it really wouldn't make much
sense.

Once we have defined what the default values are, I can modify my python
bindings patch to use these default values.

Thanks,
Tony


