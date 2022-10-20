$lines=(docker container ls --all -f "name=c_quick_bench")

$ok_msg="You can run the container: docker start c_quick_bench"

if($lines.Length -eq 2) {
    Write-Host $ok_msg
} else {
    Write-Host "Creating c_quick_bench"
    docker create -v "$(pwd)/data:/data" -v "//var/run/docker.sock:/var/run/docker.sock" --env-file "$(pwd)\local.env" -e "BENCH_ROOT=$(pwd)" -p 4000:4000 --name c_quick_bench -it fredtingaud/bench-runner ./start-quick-bench
    if($?) {
        Write-Host $ok_msg
    } else {
        Write-Host "Could not create container."
    }
}
