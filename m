From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Apr 2010 16:12:48 +0200
Subject: [PATCH 03/22] Replicator: add libdm support
In-Reply-To: <20100426134655.GM23791@agk-dp.fab.redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>	<5f5187a4b0884a93f84ce1a9c7a6baca75c9842d.1271085009.git.zkabelac@redhat.com>
	<20100426134655.GM23791@agk-dp.fab.redhat.com>
Message-ID: <4BD59F60.5060107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 26.4.2010 15:46, Alasdair G Kergon napsal(a):
> On Mon, Apr 12, 2010 at 05:21:31PM +0200, Zdenek Kabelac wrote:
>> index aa8ad5c..3ab5ea2 100644
>> --- a/libdm/libdevmapper.h
>> +++ b/libdm/libdevmapper.h
>> @@ -439,6 +439,37 @@ int dm_tree_node_add_mirror_target_log(struct dm_tree_node *node,
>>  					  const char *log_uuid,
>>  					  unsigned area_count,
>>  					  uint32_t flags);
> 
> Add comment lines that clearly separate out this section of the header file,
> indicating that the functionality and API are not yet frozen.
> 
>> +
>> +/* Replicator operation mode */
>> +typedef enum {
> 
>> +/* Replicator-log has a list of sites */
>> +/* CHECKME: maybe move to seg_area too? */
> 
> Stick with 'FIXME' for anything like that.
> 
>> @@ -1688,6 +1807,9 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
>>  			}
>>  		}
>>  
>> +		if (child->activation_priority != 0)
>> +			continue;
>> +
> 
> That change could affect non-replicator code: please separate it out and
> explain the reasoning.

True - this code seems to be no longer needed - as it's been hack to avoid
some strange tree loading in some past versions of replicator.

Zdenek


