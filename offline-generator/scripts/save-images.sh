#!/bin/bash

. ./scripts/load-config.sh

#
# Expand container image repo.
# ex)
#   registry:2       => docker.io/library/registry:2
#   rook/ceph:v1.3.2 => docker.io/rook/ceph:v1.3.2
#
expand_image_repo() {
    local repo="$1"

    if [[ "$repo" =~ ^[a-zA-Z0-9]+: ]]; then  # does not contain slash
        repo="docker.io/library/$repo"
    elif [[ "$repo" =~ ^[a-zA-Z0-9]+\/ ]]; then  # does not cotain fqdn (period)
            repo="docker.io/$repo"
    fi
    echo "$repo"
}

# Pull container image
image_pull() {
    image="$1"

    sudo docker pull $image || exit 1
    #sudo ctr -n k8s.io images pull $image || exit 1
}

# Save container image to tarball
image_save() {
    image="$1"
    out="$2"

    sudo docker save $image > "$out" || exit 1
    #sudo ctr -n k8s.io images export $out $image || exit 1
}

./scripts/install-docker.sh || exit 1
#./scripts/install-containerd.sh || exit 1

IMAGEDIR=outputs/images
if [ -e $IMAGEDIR ]; then
    /bin/rm -rf $IMAGEDIR
fi
mkdir -p $IMAGEDIR

echo "==> Pull container images"

cat imagelists/*.txt outputs/*-images.txt | sed "s/#.*$//g" | sort -u > $IMAGEDIR/images.txt
cat $IMAGEDIR/images.txt

IMAGES=$(cat $IMAGEDIR/images.txt)

for i in $IMAGES; do
    i=$(expand_image_repo $i)
    f="$(echo $i | sed 's/\//_/g').tar"

    echo "==> pulling $i"
    image_pull $i

    echo "==> saving $i to $IMAGEDIR/$f"
    image_save $i "$IMAGEDIR/$f" || exit 1
done

echo "==> Create images tarball"
mkdir -p outputs/offline-files
(cd outputs && tar cvzf offline-files/container-images.tar.gz images/)
