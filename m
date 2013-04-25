From: Tony Asleson <tasleson@redhat.com>
Date: Thu, 25 Apr 2013 14:57:32 -0500
Subject: [PATCH V4] lvm2app: Add thin and thin pool lv creation
In-Reply-To: <87r4i98ybi.fsf@in.ibm.com>
References: <1363713892-14704-1-git-send-email-mohan@in.ibm.com>
	<515DF3F3.70004@redhat.com> <87zjx47x7a.fsf@in.ibm.com>
	<516800C9.8000505@redhat.com> <5168268A.6040701@redhat.com>
	<516DAA0F.2090604@redhat.com> <87r4i98ybi.fsf@in.ibm.com>
Message-ID: <51798AAC.8090408@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/17/2013 01:29 AM, M. Mohan Kumar wrote:
> As per Zdenek, thin LV snapshot can be created from a non thin LV
> also. Should thin_lv_creation API support this feature also?

Eventually the API should support everything :-)  Lets try to get the
thin pool, thin logical volume creation worked out and then we can take
a look at this.

> Tony, here is the rebased patch.

Thanks!

-Tony


