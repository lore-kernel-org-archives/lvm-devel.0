From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Fri, 18 Dec 2009 09:01:19 -0800
Subject: [PATCH 1 of 4] Add more error codes in mirror DSO
In-Reply-To: <3F1215A5-8BF2-4DBD-99A6-6CD56352ABD4@redhat.com>
References: <patchbomb.1260695922@localhost>
	<a74600c6163e6640d0ca.1260695923@localhost>
	<3F1215A5-8BF2-4DBD-99A6-6CD56352ABD4@redhat.com>
Message-ID: <20091218170119.GA23025@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
> Is there a reason you bumped ME_IGNORE from 0 to 1?

It is actually a bit-field value rather than an absolute value, so I
couldn't have anything with zero.

> Did you forget about ME_IGNORE in 'process_event' (causing it to fall  
> through to the final else)?

Yes! Thank you. Unknown errors are handled as 'fatal' errors in the
existing code, so process_event will never get an unknown error code (it
has to be ME_IGNORE). I will fix it.


