From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Apr 2010 16:39:19 +0200
Subject: [PATCH 08/22] Replicator: extend volume_group with list of VGs
In-Reply-To: <20100426142651.GP23791@agk-dp.fab.redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>	<bc8252d38b689d788689562d40751a4f31c0daf1.1271085009.git.zkabelac@redhat.com>
	<20100426142651.GP23791@agk-dp.fab.redhat.com>
Message-ID: <4BD5A597.9040201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.4.2010 16:26, Alasdair G Kergon napsal(a):
> On Mon, Apr 12, 2010 at 05:21:36PM +0200, Zdenek Kabelac wrote:
>> Add linked list of opened VGs. List keeps the information
>> about needed and locked and opened VGs for replicator target.
>> Also add missing_vgs status information for quick check and
>> also for possible continuos process_each_lv() where we need
>> to detect whether failure has been caused by missing VG or
>> some other reason.
>  
>> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
>> index 6d40365..9c73dba 100644
>> --- a/lib/metadata/metadata-exported.h
>> +++ b/lib/metadata/metadata-exported.h
>> @@ -250,6 +250,10 @@ struct volume_group {
>> +        /* List of wanted/locked and opened VGs */
>> +	struct dm_list vgs;
>> +	uint32_t missing_vgs;
> 
> Can we think up more-specific names?
> 
> vg->vgs isn't very informative.
> 

In fact I've had there some different names - like remote_vgs, needed_vgs,
deps_vgs....
but I could not decide - and as we now already have  pvs, lvs,   vgs seems to
be natural extension of naming concept.

vgs - is list of vgnames and flags for openning, including the vg itself -
thus remote_vgs doesn't fit. Needed - seems plain ugly.

So I'm open for new names here - note there are some manipulation functions
which should also use this name.

Zdenek


