From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Mon, 06 May 2013 21:18:54 +0530
Subject: [PATCH] lvm2app: Add thin and thin pool lv creation V2
In-Reply-To: <5187CE2E.8060309@redhat.com>
References: <1367597312-7157-1-git-send-email-tasleson@redhat.com>
	<87k3ncck85.fsf@in.ibm.com> <5187CE2E.8060309@redhat.com>
Message-ID: <87bo8ocdnd.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Tony Asleson <tasleson@redhat.com> writes:

> On 05/06/2013 08:26 AM, M. Mohan Kumar wrote:
>> Tony Asleson <tasleson@redhat.com> writes:
>> 
>>> + *
>>> + */
>>> +lv_create_params_t lvm_lv_params_create_thin_pool(vg_t vg,
>>> +		const char *pool_name, uint64_t size, uint32_t chunk_size,
>>> +		uint64_t meta_size, lvm_thin_discards_t discard);
>>> +
>>> +#define lvm_lv_params_create_thin_pool_default(vg, pool_name, size) \
>>> +			lvm_lv_params_create_thin_pool((vg), (pool_name), (size), 0, 0, \
>>> +			LVM_THIN_DISCARDS_PASSDOWN)
>>> +
>>> +
>>> +/**
>>> + * Set the value of zero skip for the lv_create_params
>>> + *
>>> + * \param params
>>> + * lv_create_prams to change
>>> + *
>>> + * \param skip
>>> + * Value of skip zero to be set (0 == zero, 1 == skip zero)
>>> + *
>>> + * \return
>>> + * 0 on success, else -1
>>> + */
>>> +int lvm_lv_params_skip_zero_set(lv_create_params_t params, int skip);
>> 
>> Are we going to provide as many helper functions to get/set parameters
>> in lv_create_params structure? For example if an user does wants a new
>> LV to be created in deactivation state, should we provide a helper
>> something like this?
>> 
>> int lvm_lv_params_activation_set(lv_create_params_t params, int
>> activate);
>> 
>> In this case lvm-api wont be flooded with lots of helper functions?
>> Instead of individual helper function how about a common helper function
>> to take care of this?
>> 
>> int lvm_lv_params_set(lv_create_params_t params, enum lv_create_param_type,
>>                       type, void *data);
>> 
>> lvm_lv_params_set function will validate 'data' based on the
>> lv_create_param_type and will return error if 'data' does not match
>> given enum (resource)?
>> 
>> enum lv_create_param_type {
>>      LV_CR_INVALID,
>>      LV_CR_ZERO,
>>      LV_CR_ACTIVATION,
>> 
>>      LV_CR_MAX_PARAM,
>> };
>> 
>> In above zero case, this function will be invoked like this:
>> 
>> lvm_lv_params_set(params, LV_CR_ZERO, &zero);
>> 
>> lvm_lv_params_set will do:
>>                   switch (type) {
>>                   case LV_CR_ZERO:
>>                      memcpy (&zero_skip, data, sizeof(int));
>>                      break;
>>                   case LV_CR_ACTIVATION:
>>                        memcpy (&activation, data, sizeof(int));
>>                        if (activation < CHANGE_AY && activation >
>>                           CHANGE_AAY) {
>>                           log_error();
>>                           return -1;
>>                        }
>>                   }
>> 
>> 
>
> Yeah, this is probably a better approach to minimize API explosion.  The
> only thing I would like to add is a size_t data_len field.  This way we
> can accommodate variable size data for same operation.
>
> Does that sound reasonable?  I guess if we only support simple fixed
> type sizes it would be redundant.
>
+1 


