From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 21:23:28 +0100
Subject: [PATCH 06/24] lv_info handle udev_sync
In-Reply-To: <4D45C768.6090306@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
	<9a4defa6949857ab698f1d25e5779d422c5cdcc6.1296391340.git.zkabelac@redhat.com>
	<4D45C768.6090306@redhat.com>
Message-ID: <4D45C8C0.8050207@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.1.2011 21:17, Milan Broz napsal(a):
> On 01/30/2011 01:57 PM, Zdenek Kabelac wrote:
> 
>> NoteII: locking_is_clustered() is needed to detect in which context
>> lv_info() is called as we cannot use sync_local_dev_names() when
>> locking is not defined.
> 
> hmmmm. I probably confused you here:)
> 
> I don't think locking_is_clustered() can be used insinde clvmd
> (it is "locking implementation" itself).
> 
> Or you mean it that in clvmd should run fs_unlock() and in local
> code (lvm command) should run sync_local_dev_names(cmd) (with cluster locking)?

Yes - that's the intention

In clvmd - locking is not initilized - so sync_local_dev_names() cannot be used.


> 
>> +	/*
>> +	 * If open_count info is requested and we have to be sure our own udev
>> +	 * transactions are finished
>> +	 * For non-clustered locking type we are only interested for non-delete operation
>> +	 * in progress - as only those could lead to opened files
>> +	 */
>> +	if (with_open_count) {
>> +		if (locking_is_clustered())
>> +			sync_local_dev_names(cmd); /* Wait to have udev in sync */
>> +		else if (fs_has_non_delete_ops())
>> +			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
>> +	}
> 
> this is really ugly...

Yes I know - plan for the future would be to hide this logic directly to
sync_local_dev_names() -  so only sync_local_dev_name() would stay there.

Zdenek


