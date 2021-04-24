docker build -q -t ana .
docker run --rm --name ana -d -p 8080:8080 -e READ_MEMORY_API=http://localhost:8080/api/v1/debug/readMemory ana

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":166,"state":{"a":255,"b":1,"c":15,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":166,"state":{"a":10,"b":1,"c":15,"d":5,"e":15,"h":10,"l":2,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":true,"carry":false},"programCounter":1,"stackPointer":2,"cycles":7}}'

docker kill ana

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mANA Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mANA Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi