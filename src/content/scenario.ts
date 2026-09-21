import type { ScenarioContent } from '../domain/types';

export const kindnessCrewScenario: ScenarioContent = {
  id: 'kindness-crew-courtyard',
  title: 'Kindness Crew: Courtyard Choice',
  ageRange: '8-12',
  estimatedMinutes: '8-12 minutes',
  safetyNote:
    'This practice story uses calm school situations, no personal data, no public chat, and no scoring. If someone feels unsafe in real life, tell a trusted adult right away.',
  optionalBackgroundAsset: 'assets/courtyard.png',
  startSceneId: 'courtyard-start',
  scenes: [
    {
      id: 'courtyard-start',
      title: 'After Art Club',
      location: 'School courtyard',
      body:
        'Art club has just ended. You notice Sam sitting quietly by the planter while three classmates laugh about the nickname they wrote on a scrap of paper. Sam is not hurt, but Sam looks uncomfortable and alone. You are a bystander: you can choose a safe way to help, get adult help, redirect the moment, or wait and watch.',
      prompt: 'What is a safe first step?',
      choices: [
        {
          id: 'private-support',
          label: 'Check on Sam privately.',
          description: 'Move beside Sam and ask, “Want to walk with me for a minute?”',
          nextSceneId: 'private-check-in',
          safetyTag: 'supportive',
        },
        {
          id: 'trusted-adult',
          label: 'Find a trusted adult.',
          description: 'Tell Ms. Rivera, the art teacher, what you noticed.',
          nextSceneId: 'adult-help',
          safetyTag: 'trusted-adult',
        },
        {
          id: 'safe-redirection',
          label: 'Redirect without making a scene.',
          description: 'Ask everyone to help carry the art supplies back inside.',
          nextSceneId: 'redirect-supplies',
          safetyTag: 'redirect',
        },
        {
          id: 'wait-watch',
          label: 'Wait and watch for a moment.',
          description: 'Stay nearby because you are unsure what to do.',
          nextSceneId: 'watching',
          safetyTag: 'observe',
        },
      ],
    },
    {
      id: 'private-check-in',
      title: 'A Quiet Check-In',
      location: 'Path near the library',
      body:
        'Sam walks with you toward the library doors. Sam says, “I wish they would stop using that nickname.” Sam does not want a big crowd around them.',
      prompt: 'How can you support Sam while keeping things respectful?',
      choices: [
        {
          id: 'listen-offer-adult',
          label: 'Listen, then offer adult help.',
          description: 'Say, “I can stay with you while we tell Ms. Rivera or another adult.”',
          nextSceneId: 'ending-supported-adult',
          safetyTag: 'trusted-adult',
        },
        {
          id: 'invite-friend',
          label: 'Invite Sam into a safer activity.',
          description: 'Ask Sam to help choose where the art posters should hang.',
          nextSceneId: 'ending-private-support',
          safetyTag: 'supportive',
        },
        {
          id: 'promise-secret',
          label: 'Promise not to tell anyone ever.',
          description: 'Try to make Sam feel better by promising total secrecy.',
          nextSceneId: 'secrecy-check',
          safetyTag: 'mixed',
        },
      ],
    },
    {
      id: 'adult-help',
      title: 'Trusted Adult Help',
      location: 'Art room doorway',
      body:
        'Ms. Rivera thanks you for speaking up calmly. She asks what you saw, then says she will check on Sam and handle the paper nickname without blaming anyone in front of the whole courtyard.',
      prompt: 'What can you do next?',
      adultHelp: 'Trusted adults can include teachers, counselors, coaches, family adults, or another grown-up who keeps kids safe.',
      choices: [
        {
          id: 'stay-nearby',
          label: 'Stay nearby as a friendly classmate.',
          description: 'Give Sam space while showing they are not alone.',
          nextSceneId: 'ending-supported-adult',
          safetyTag: 'trusted-adult',
        },
        {
          id: 'announce-report',
          label: 'Tell the whole group you reported them.',
          description: 'You feel upset and want everyone to know.',
          nextSceneId: 'public-callout-check',
          safetyTag: 'mixed',
        },
      ],
    },
    {
      id: 'redirect-supplies',
      title: 'A Gentle Redirection',
      location: 'Courtyard table',
      body:
        'Your supply request changes the energy. Two classmates pick up folders. The scrap of paper is still on the table, and Sam is still quiet.',
      prompt: 'What makes the redirection safer and more helpful?',
      choices: [
        {
          id: 'remove-paper-adult',
          label: 'Ask an adult to handle the paper.',
          description: 'Quietly tell Ms. Rivera where the paper is and what happened.',
          nextSceneId: 'ending-safe-redirect',
          safetyTag: 'trusted-adult',
        },
        {
          id: 'pair-with-sam',
          label: 'Pair up with Sam for the supply job.',
          description: 'Say, “Sam, can you help me with these posters?”',
          nextSceneId: 'ending-safe-redirect',
          safetyTag: 'redirect',
        },
        {
          id: 'grab-paper-wave',
          label: 'Grab the paper and wave it around.',
          description: 'You want to prove the nickname was not okay.',
          nextSceneId: 'public-callout-check',
          safetyTag: 'mixed',
        },
      ],
    },
    {
      id: 'watching',
      title: 'Waiting Nearby',
      location: 'Courtyard bench',
      body:
        'You wait because you do not want to make things worse. The laughing gets quieter, but Sam still sees the paper and leaves the courtyard alone.',
      prompt: 'Doing nothing can feel easier. What could you do now?',
      choices: [
        {
          id: 'follow-kindly',
          label: 'Check on Sam from a respectful distance.',
          description: 'Ask, “Do you want company, or should I get an adult?”',
          nextSceneId: 'private-check-in',
          safetyTag: 'supportive',
        },
        {
          id: 'tell-adult-after',
          label: 'Tell a trusted adult what you noticed.',
          description: 'Share the facts with Ms. Rivera even though the moment passed.',
          nextSceneId: 'adult-help',
          safetyTag: 'trusted-adult',
        },
        {
          id: 'keep-doing-nothing',
          label: 'Keep doing nothing today.',
          description: 'You decide not to get involved this time.',
          nextSceneId: 'ending-do-nothing',
          safetyTag: 'do-nothing',
        },
      ],
    },
    {
      id: 'secrecy-check',
      title: 'About Promising Secrecy',
      location: 'Library steps',
      body:
        'Sam appreciates that you listened. Still, promising never to tell an adult can make it harder to get help if the nickname keeps happening. A safer promise is: “I will not spread this around, and I can help you choose a trusted adult.”',
      prompt: 'Reflection',
      reflection:
        'What promise keeps privacy respectful while still allowing help from a trusted adult if the problem continues?',
      ending: 'supportive',
      choices: [],
    },
    {
      id: 'public-callout-check',
      title: 'When Helping Gets Too Public',
      location: 'Courtyard table',
      body:
        'Calling people out loudly can sometimes make the targeted person feel more watched. You can still repair the moment by lowering the attention and getting help calmly.',
      prompt: 'Reflection',
      reflection: 'How could you lower attention and repair a public callout if helping becomes too loud?',
      ending: 'redirect',
      choices: [],
    },
    {
      id: 'ending-private-support',
      title: 'Ending: Private Support',
      location: 'Poster wall',
      body:
        'Sam spends the next few minutes choosing poster spots with you. The nickname paper is no longer the focus, and Sam knows one classmate noticed with kindness. Private support can reduce loneliness, and it can be paired with adult help if the problem continues.',
      prompt: 'Reflection',
      reflection: 'What words could you use to check on someone without pressuring them to talk?',
      ending: 'supportive',
      choices: [],
    },
    {
      id: 'ending-supported-adult',
      title: 'Ending: Trusted Adult Help',
      location: 'Art room',
      body:
        'Ms. Rivera checks on Sam and handles the nickname paper calmly. You helped by sharing facts and not turning the moment into a public show. Getting a trusted adult is a strong bystander choice, especially when a problem might repeat or feel unsafe.',
      prompt: 'Reflection',
      reflection: 'Who are two trusted adults a student could go to at school or at home?',
      adultHelp: 'If anyone is in danger, threatened, or repeatedly targeted, get trusted-adult help right away.',
      ending: 'trusted-adult',
      choices: [],
    },
    {
      id: 'ending-safe-redirect',
      title: 'Ending: Safe Redirection',
      location: 'Hallway display',
      body:
        'The group moves on to cleaning up, and Sam gets a calmer way out of the moment. Redirection works best when it lowers attention, avoids insults, and leaves room to check in or tell an adult afterward.',
      prompt: 'Reflection',
      reflection: 'What is one neutral activity that could safely interrupt an uncomfortable moment?',
      ending: 'redirect',
      choices: [],
    },
    {
      id: 'ending-do-nothing',
      title: 'Ending: Doing Nothing This Time',
      location: 'Courtyard bench',
      body:
        'You stayed out of it, and the courtyard became quiet. Sam was left to handle the uncomfortable moment alone. This is not about blame: bystanders can freeze or feel unsure. Next time, a small safe step—private support, adult help, or gentle redirection—could make things better.',
      prompt: 'Reflection',
      reflection: 'If you froze at first, what small safe step could you take after the moment passes?',
      ending: 'do-nothing',
      choices: [],
    },
  ],
};
