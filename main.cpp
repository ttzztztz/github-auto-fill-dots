#include <iostream>
#include <cstring>
#include <fstream>
#include <unistd.h>
#include <ctime>
#include <sstream>

std::string build_command(int days_ago, const char *command) {
    if (days_ago == 0) {
        return command;
    } else {
        std::string result = "LD_PRELOAD=/usr/local/lib/faketime/libfaketime.so.1 FAKETIME_NO_CACHE=1 FAKETIME=\"-";
        result.append(std::to_string(days_ago));
        result.append("d\" ");
        result.append(command);
        return result;
    }
}

int main() {
    std::time_t timestamp = time(nullptr);

    for (int i = 375; i >= 0; i--) {
        std::fstream rand_stream;

        std::stringstream ss;
        std::time_t currTimestamp = timestamp - (i * 24 * 60);
        ss << "/home/repo/fake_file_" << currTimestamp << ".temp";
        std::string fake_file_path;
        ss >> fake_file_path;

        rand_stream.open(fake_file_path, std::ios_base::out);
        rand_stream << currTimestamp;
        rand_stream.close();

        std::cout << i << " will push to remote repo." << std::endl;

        std::string command = "cd /home/repo && git add . && ";
        std::string fakeTimeCommand = build_command(i, "git commit -m \"daily commit\"");

        command.append(fakeTimeCommand);
        std::cout << command << std::endl;
        system(command.data());
    }

    system("cd /home/repo && git push -u origin master");
    std::cout << "exec successful!" << std::endl;
    return 0;
}