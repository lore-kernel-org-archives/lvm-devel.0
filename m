From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 9 Jun 2017 13:58:11 +0200
Subject: master - cleanup: rename internal define
In-Reply-To: <734fcc30-58bd-d778-72d2-7f8d8a73d4d0@redhat.com>
References: <201706081003.v58A3TQY007752@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<734fcc30-58bd-d778-72d2-7f8d8a73d4d0@redhat.com>
Message-ID: <71c3f841-41e5-81c7-c4fb-7f44abda490d@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 9.6.2017 v 13:48 Marian Csontos napsal(a):
> On 06/08/2017 12:03 PM, Zdenek Kabelac wrote:
>> Gitweb:        
>> https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=719d0996930dfad8608c49af2f81008b6ca77cb8 
>>
>> Commit:        719d0996930dfad8608c49af2f81008b6ca77cb8
>> Parent:        39703cb48514415633bc027e49e99e1ee7c4bbb4
>> Author:        Zdenek Kabelac <zkabelac@redhat.com>
>> AuthorDate:    Fri Jun 2 11:18:04 2017 +0200
>> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
>> CommitterDate: Thu Jun 8 11:07:18 2017 +0200
>>
>> cleanup: rename internal define
>>
>> More descriptive name of #define.
>> ---
>>   lib/config/defaults.h     |    2 +-
>>   lib/metadata/thin_manip.c |    2 +-
>>   liblvm/lvm_lv.c           |    2 +-
>>   3 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/lib/config/defaults.h b/lib/config/defaults.h
>> index 65b81f1..05747fa 100644
>> --- a/lib/config/defaults.h
>> +++ b/lib/config/defaults.h
>> @@ -106,7 +106,7 @@
>>   #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
>>   #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
>>   #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */
>> -#define DEFAULT_THIN_POOL_OPTIMAL_SIZE     (128 * 1024 * 1024)    /* KB */
>> +#define DEFAULT_THIN_POOL_OPTIMAL_METADATA_SIZE (128 * 1024 * 1024) /* KB */
> 
> Inconsistency here:
> 
> Should this be B instead of KB?
> 
> Or 128 * 1024 to make it consistent with the rest, and adjust calculations later?
> 

Hi

Thanks for noticing, you are possibly right - I should've also clean the 
numbers so we could drop sectorsize from calcs

I'll take a look.

Zdenek


