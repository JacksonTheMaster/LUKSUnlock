<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/jacksonthemaster/LUKSUnlock">
    <img src="https://raw.githubusercontent.com/JacksonTheMaster/LUKSUnlock/main/LUKSUnlock.png" alt="Logo" width="250" height="250">
  </a>
<h3 align="center">LUKSUnlock</h3>

<p align="center">
  Enhance your system's security by leveraging YubiKey for LUKS encryption, ensuring your data remains protected and accessible only to you. Simplify the encryption process and take control of your digital security.
  <br />
  <a href="https://github.com/JacksonTheMaster/LUKSUnlock"><strong>Explore the LUKSUnlock documentation and get started »</strong></a>
  <a href="https://docs.jmg-it.de/docs/"><strong>Explore the LUKSUnlock docs in the JMG Docs (not public yet :D) »</strong></a>
</p>

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

[![bash][bash.sh]][bash-url]


This project was built with bash for debian based Linux environments.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## What does this do?

This innovative script revolutionizes the process of securing your data by automating the creation of a LUKS-encrypted container, with a twist - it unlocks using your YubiKey. Imagine the simplicity: Plug in your YubiKey, boot your device, and voila, your mount point remains securely unlocked as long as you're using it, yet instantly locks the moment you or anybody else may boot without the YubiKey.This method not only elevates the security of your data storage but does so with an unprecedented level of convenience and ease.

Designed for users who prioritize robust security without wanting to compromise on accessibility, this script transforms the way you protect your digital life. Whether you're safeguarding sensitive work documents, personal memories, or critical system files, our YubiKey-LUKS integration ensures your data remains secure yet effortlessly accessible with just a simple plug & boot with your YubiKey.

## Getting Started

Embark on a journey to unparalleled data security with our YubiKey-LUKS integration. This guide will navigate you through every step needed to fortify your digital vault. From meeting the initial prerequisites to the final installation and daily usage, we've streamlined the process to be as user-friendly as possible, ensuring you can enhance your system's security without needing to be a tech guru. Let's dive in and unlock a new era of data protection together.


### Prerequisites

- A Linux system with LUKS support
- A YubiKey with an empty slot 2 for challenge-response OTP configuration

### Installation

Embark on fortifying your data security with a few simple steps. Whether you're cloning this repository or opting for a direct script download for quick access, you're moments away from enhanced protection:

1. **Clone the Repository**: Grab the latest version, open your terminal, go to a folder of your choise where we can work and execute:
   ```bash
   git clone https://github.com/JacksonTheMaster/LUKSUnlock.git
   ```
### Setup

Embark on securing your digital assets by simply executing `install.sh`. This initiates a guided setup, meticulously crafting a LUKS encrypted container, followed by configuring your YubiKey for a seamless security experience.

**Please Note:**

**By default, the script crafts a 276MB LUKS container at /cryptstore, mounted at /secureLUKS. The size is striking the balance between speed and functionality for your testing process. This size is chosen as a practical default, understanding that encrypting significantly larger volumes, such as 400GB, could extend setup times considerably. This initial size serves most immediate security needs while keeping the setup swift.**

**However, Flexibility is Key:**

Designed to cater to diverse needs, the `install.sh` script embodies flexibility, allowing you to customize your LUKS container and YubiKey setup effortlessly. With intuitive command line options, adjust the configuration to fit your exact requirements without diving into the script's internals. Each option empowers you to:

- **Display Help Menu (`-h`)**: Display the Console help (this, basically)
  
- **Customize Storage Path (`-s`)**: Specify the exact location for your encrypted container, enabling you to align with your storage organization or utilize separate partitions.
  
- **Name Your Container (`-f`)**: Personalize the container file name, facilitating easy identification among multiple containers or simply to align with your naming conventions.
  
- **Designate the Mount Directory (`-d`)**: Choose where your unlocked container will be accessible, tailoring the mount point to fit seamlessly into your directory structure.
  
- **Allocate Container Size (`-b`)**: Decide on the size of your encrypted container, giving you the freedom to scale up for more storage or scale down for quicker setup times.
  
- **Select the Mapper Name (`-m`)**: Define how the decrypted container is identified under `/dev/mapper/`, enhancing clarity and avoiding potential conflicts.

This blend of guided setup and customizable options ensures that bolstering your system's security with LUKS and YubiKey not only enhances protection but also respects your unique setup preferences and requirements.


### Uninstall

To remove the configuration and clean up installed components, run the `uninstall.sh` script.

Similarly, the flexibility of the `install.sh` script extends to the uninstallation process through the `uninstall.sh` script, allowing you to use the same command line arguments to specify your setup during removal. This ensures that the uninstallation process is tailored to your custom configuration, correctly targeting the container storage path, container file name, mount directory, container size, and mapper name you initially set up. By mirroring the installation arguments, the `uninstall.sh` script ensures a thorough and clean removal of all components related to your YubiKey-LUKS setup, leaving no traces behind.

You can run install.sh and uninstall.sh in a loop without the need for rebooting or any else action.



### Closing

After setup, your LUKS container can be mounted and unmounted as needed. It will automatically unlock with your YubiKey on system boot.



<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

Once installed, your LUKS container will automatically unlock when the YubiKey is inserted during boot. For manual unlocking or management, refer to the `cryptsetup` and `ykchalresp` commands.

## Roadmap & Known issues

For future updates, enhancements, and current known issues, please refer to the open issues section on GitHub.

See the [open issues](https://github.com/jacksonthemaster/LUKSUnlock/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

<!-- ROADMAP & Known issues-->
## Roadmap & Known issues


See the [open issues](https://github.com/jacksonthemaster/LUKSUnlock/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

J. Langisch - [@langischjs](https://twitter.com/langischjs) - j.langisch@jmg-it.de

Project Link: [https://github.com/jacksonthemaster/LUKSUnlock](https://github.com/jacksonthemaster/LUKSUnlock)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgements

* My wife for not seeing me in a day
* [Reddit](Reddit)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/jacksonthemaster/LUKSUnlock.svg?style=for-the-badge
[contributors-url]: https://github.com/jacksonthemaster/LUKSUnlock/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/jacksonthemaster/LUKSUnlock.svg?style=for-the-badge
[forks-url]: https://github.com/jacksonthemaster/LUKSUnlock/network/members
[stars-shield]: https://img.shields.io/github/stars/jacksonthemaster/LUKSUnlock.svg?style=for-the-badge
[stars-url]: https://github.com/jacksonthemaster/LUKSUnlock/stargazers
[issues-shield]: https://img.shields.io/github/issues/jacksonthemaster/LUKSUnlock.svg?style=for-the-badge
[issues-url]: https://github.com/jacksonthemaster/LUKSUnlock/issues
[license-shield]: https://img.shields.io/github/license/jacksonthemaster/LUKSUnlock.svg?style=for-the-badge
[license-url]: https://github.com/jacksonthemaster/LUKSUnlock/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/powershell-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[ps-url]: https://microsoft.com/
[Powershell.ps1]: https://img.shields.io/badge/Powershell-4579d4?style=for-the-badge&logo=Powershell&logoColor=white
[download-url]: https://github.com/JacksonTheMaster/LUKSUnlock/releases
[download]: https://img.shields.io/badge/Take%20me%20to%20the%20downloads-e7141a?style=for-the-badge&logo=Github&logoColor=white
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
