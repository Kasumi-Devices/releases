curl --data parse_mode=HTML --data chat_id=$KASUMI_CHAT --data sticker="CAACAgQAAxkBAAI162ITa4G_fYgSTH7lkqzxSL4NT_H2AAJYCgAC9jq5U2_Xu32QCRsVIwQ" --request POST https://api.telegram.org/bot$KASUMI_TOKEN/sendSticker
echo ""
source ${my_dir}/config.sh
source ${my_dir}/maintainervars.sh
if [ ! -z "${credits}" ]; then
    telegram -t ${KASUMI_TOKEN} -c ${KASUMI_CHAT} -i ${my_dir}/assets/kasumi.png -T "New build for ${ROM_VERSION}~!" -H "Made for ${devicecode}, by ${mntnrtg}

Official build
Signed
Build type: ${variant}
${addonstat}
Face unlock ${facestat}.

<a href='https://dl.ayokaacr.net/4:/${device}/${zip_name}'>Download</a>
${credits}"
else
    telegram -t ${KASUMI_TOKEN} -c ${KASUMI_CHAT} -i ${my_dir}/assets/kasumi.png -T "New build for ${ROM_VERSION}~!" -H "Made for ${devicecode}, by ${mntnrtg}

Official build
Signed
Build type: ${variant}
${addonstat}
Face unlock ${facestat}.

<a href='https://dl.ayokaacr.net/4:/${device}/${zip_name}'>Download</a>"
fi
