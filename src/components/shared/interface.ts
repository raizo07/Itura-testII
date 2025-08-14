export  interface Data {
    id: number;
    title: string;
    icon: string;
}

export interface Messages {
  type: string;
  sender: string;
  content: string | { src: string; alt?: string; title?: string };
}

export interface Cards {
  title: string;
  subtitle: string;
  description: string;
  img: string;
}

export interface SlideItem extends Data {
  image: string;
  details: string;
}