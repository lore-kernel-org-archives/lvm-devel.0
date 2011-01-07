From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 07 Jan 2011 14:49:16 +0100
Subject: [PATCH 2/8] Add default error path for get_property
In-Reply-To: <20110107134141.GC5910@agk-dp.fab.redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>	<6bbe3896c9173603df3be06a3e60dd79f339e028.1294398815.git.zkabelac@redhat.com>
	<20110107134141.GC5910@agk-dp.fab.redhat.com>
Message-ID: <4D2719DC.1030008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.1.2011 14:41, Alasdair G Kergon napsal(a):
> On Fri, Jan 07, 2011 at 12:17:30PM +0100, Zdenek Kabelac wrote:
>> +			log_errno(EINVAL, "Invalid query for property.");
> 
> Do we have any information about the property to include in that error
> message, such as its name?
> 

No - all parameters passed to get_property are NULL in this case -
so programmer's error.

Zdenek


