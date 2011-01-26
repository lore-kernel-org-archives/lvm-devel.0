From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 26 Jan 2011 11:38:52 +0100
Subject: [PATCH 02/17] Add supporting functions for metadata areas stored in format instance.
In-Reply-To: <87pqrlrune.fsf@twilight.int.mornfall.net.>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>	<1295867048-21558-3-git-send-email-prajnoha@redhat.com>
	<87pqrlrune.fsf@twilight.int.mornfall.net.>
Message-ID: <4D3FF9BC.9080401@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/25/2011 02:16 PM +0100, Petr Rockai wrote:
>>  struct format_instance {
>>  	const struct format_type *fmt;
>> +	int pv_only;
> 
> Could this be changed to an enumerated "type" field, instead of pv_only?
> If I understand correctly, types are mutually exclusive anyway, and
> pv_only is rather confusing and non-obvious when reading the code.
> 

Yes, these are mutually exclusive and it'll always be only a switch
between PV and VG, or I hope so... Using a enumerated type field - OK,
no problem, whatever that makes the switch...

>> +
>>  	/*
>>  	 * Each mda in a vg is on exactly one of the below lists.
>>  	 * MDAs on the 'in_use' list will be read from / written to
>> @@ -181,6 +183,7 @@ struct format_instance {
>>  	 */
>>  	struct dm_list metadata_areas_in_use;
>>  	struct dm_list metadata_areas_ignored;
>> +	void *metadata_areas_index;
> 
> I don't currently expect that we would need as much genericity as void *
> offers (and that we could use a little extra safety). Would an union be
> better here, with an explicit list of types that can go in?
> 

Well, my incentive here was to keep this for any future changes so the
format-specific code can decide and use any type of index we can imagine.
We have this "metadata.c" layer and then the "format-specific" layer
underneath that. So adding any new format with a brand new indexing
scheme that is fine-tuned and suitable for that one new format would
require breaking the abstraction layer (so defining a new type of index
used in new format in the "metadata.c" layer above). So my incentive was
to make the index transparent for the "metadata.c" layer.

(I know, we have these "fid_{add,remove,get}_mda" functions that work
directly with the index in "metadata.c" now, but that may eventually
evolve into format-specific "fid" functions later. But since we have
only one format that actually make real use of the format instance,
I kept it in that metadata.c layer for now...)

But if we expect to use the same index scheme all the time for all
possible formats, not changing it too much, then sure, we can use a
union there... But I'd like to avoid too much editing in the future :)

>> +static int _convert_key_to_string(const char *key, size_t key_len,
>> +				  unsigned subkey, char *buf, size_t buf_len)
>>  {
>> +	memcpy(buf, key, key_len);
>> +	buf += key_len;
>> +	buf_len -= key_len;
>> +	if ((dm_snprintf(buf, buf_len, "_%u", subkey) == -1))
>> +		return_0;
>> +
>> +	return 1;
>> +}
> 
> Would it be better to require that key is NULL-terminated? It would
> simplify a lot of code, by not needing to pass the length as an extra

...if we can make sure that PV id is always terminated with 0, then OK.
But otherwise we would need to call this "convert_to_string" function
everywhere around the code (actually that was in my original working
version of this patchset, then I decided to put it in one place instead).

> parameter everywhere. I know that currently we keep the PV/VG/... IDs in
> unterminated strings, but I am quite sure this is not a good idea. I
> wouldn't expect it to be a *lot* of work to change things to keep a NULL
> termination in there as well. Maybe in a followup patch?

..thing with PV id is that we store that as a "struct id" which internally
is an array of integeres... Hmm, so you want to put another array item with
0 at the end?

BTW, we also do this "convert_to_string" in the cache code... So yes, maybe
it would be fine to clean this up somehow...

> 
>> +int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
>> +		 const char *key, size_t key_len, const unsigned subkey)
>> +{
>> +	char extended_key[PATH_MAX];
>> +
>>  	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
>>  					  &fid->metadata_areas_in_use, &mda->list);
>> +
>> +	/*
>> +	 * Return if the mda is not supposed to be
>> +	 * indexed or the index itself is not initialised */
>> +	if (!key || !fid->metadata_areas_index)
>> +		return 1;
>> +
>> +	if (!_convert_key_to_string(key, key_len, subkey,
>> +				    extended_key, PATH_MAX))
>> +		return_0;
>> +
>> +	/* Add metadata area to index. */
>> +	if (fid->pv_only)
>> +		((struct metadata_area **)fid->metadata_areas_index)[subkey] = mda;
> 
> In this branch, all the extended_key logic above is useless. It could be
> made more obvious that only the else branch needs extended_key, by
> restructuring the code. Also, is key, subkey and extended_key the right
> naming scheme? Maybe full_key instead of extended? And maybe sub_key,
> for consistency?
> 

OK...

>> +struct metadata_area *fid_get_mda_indexed(struct format_instance *fid,
>> +					  const char *key, size_t key_len,
>> +					  const unsigned subkey)
>> +{
>> +	char extended_key[PATH_MAX];
>> +	struct metadata_area *mda = NULL;
>> +
>> +	if (!_convert_key_to_string(key, key_len, subkey,
>> +				    extended_key, PATH_MAX))
>> +		return_NULL;
>> +
>> +	if (fid->pv_only)
>> +		mda = ((struct metadata_area **)fid->metadata_areas_index)[subkey];
>> +	else
>> +		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index,
>> +							      extended_key);
> 
> Same about extended_key as above (both path coverage and naming).
> 

OK...

>> +int fid_remove_mda(struct format_instance *fid, struct metadata_area *mda,
>> +		   const char *key, size_t key_len, const unsigned subkey)
>> +{
>> +	struct metadata_area *mda_indexed = NULL;
>> +	char extended_key[PATH_MAX];
>> +
>> +	/* At least one of mda or key must be specified. */
>> +	if (!mda && !key)
>> +		return 1;
>> +
>> +	if (key) {
>> +		/*
>> +		 * If both mda and key specified, check given mda
>> +		 * with what we find using the index and return
>> +		 * immediately if these two do not match.
>> +		 */
>> +		if (!(mda_indexed = fid_get_mda_indexed(fid, key, key_len, subkey)) ||
>> +		     (mda && mda != mda_indexed))
>> +			return 1;
>> +
>> +		if (!_convert_key_to_string(key, key_len, subkey,
>> +					    extended_key, PATH_MAX))
>> +			return_0;
>> +
>> +		mda = mda_indexed;
>> +
>> +		if (fid->pv_only)
>> +			((struct metadata_area**)fid->metadata_areas_index)[subkey] = NULL;
>> +		else
>> +			dm_hash_remove(fid->metadata_areas_index, extended_key);
> 
> Redundant code paths again.
> 

OK... :)

Peter


