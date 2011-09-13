From: Joe Thornber <thornber@redhat.com>
Date: Tue, 13 Sep 2011 16:01:55 +0100
Subject: [PATCH] Retry dm device removal if busy
In-Reply-To: <4E6F6ECE.4070700@redhat.com>
References: <4E6F6958.5020609@redhat.com>
 <4E6F6ECE.4070700@redhat.com>
Message-ID: <20110913150154.GA6342@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 13, 2011 at 04:55:10PM +0200, Milan Broz wrote:
> Before anyone start to complain:
> 
> we spent incredible amount of time with fixing the unfixable,
> 
> I really prefer make it to work despite it is not 100% correct.
> It is ugly but it will allow us to fix another things and not
> waste time here for now.
> 
> This approach is already used in cryptsetup, mdadm and perhaps
> other similar packages.

I've resorted to doing exactly this in the thin test suite.

- Joe


