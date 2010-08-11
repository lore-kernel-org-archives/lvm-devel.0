From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Wed, 11 Aug 2010 09:33:54 +0200
Subject: [PATCH] clvmd init: populate Required-Start/Stop at configure time
In-Reply-To: <4C625026.1050201@redhat.com>
References: <4C625026.1050201@redhat.com>
Message-ID: <4C625262.9070900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 8/11/2010 9:24 AM, Fabio M. Di Nitto wrote:
> Based on auto-detection or user requested cluster managers for clvmd,
> set appropriate Required-Start and Required-Stop at configure time.
> 
> Reorder the checks for user selected cluster managers to match auto
> detected ones, to be consistent in the output.
> 
> Add special case for qdiskd that?s started after cman/lock_gulmd for
> RHEL-4/RHEL-5.
> 
> Tested on RHEL-4, 5 and 6 and it seems to work fine. I?d really
> appreciate some extra testings tho.
> 
> Fabio


Forgot one side note, my autoreconf diff is somewhat gigantic and I
don?t feel comfortable to push it. I can commit the patch, but i?d
prefer if somebody else would run autoreconf for me.

Fabio


