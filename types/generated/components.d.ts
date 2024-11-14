import type { Schema, Struct } from '@strapi/strapi';

export interface ElementsButton extends Struct.ComponentSchema {
  collectionName: 'components_elements_buttons';
  info: {
    description: '';
    displayName: 'Button';
    icon: 'link';
  };
  attributes: {
    href: Schema.Attribute.Text & Schema.Attribute.Required;
    page: Schema.Attribute.Relation<'oneToOne', 'api::page.page'>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
    variant: Schema.Attribute.Enumeration<['primary', 'secondary']>;
  };
}

export interface ElementsListItemWithIcon extends Struct.ComponentSchema {
  collectionName: 'components_elements_list_item_with_icons';
  info: {
    displayName: 'List Item with Icon';
    icon: 'bulletList';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    image: Schema.Attribute.Media<'images'> & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface ElementsSocial extends Struct.ComponentSchema {
  collectionName: 'components_elements_socials';
  info: {
    displayName: 'Social';
    icon: 'heart';
  };
  attributes: {
    isEnabled: Schema.Attribute.Boolean &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<false>;
    link: Schema.Attribute.String & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiHero extends Struct.ComponentSchema {
  collectionName: 'components_ui_heroes';
  info: {
    description: '';
    displayName: 'Hero';
    icon: 'landscape';
  };
  attributes: {
    CTO: Schema.Attribute.Component<'elements.button', false>;
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    images: Schema.Attribute.Media<'images', true> & Schema.Attribute.Required;
    link: Schema.Attribute.Component<'elements.button', false>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface UiKernwaarden extends Struct.ComponentSchema {
  collectionName: 'components_ui_kernwaardens';
  info: {
    description: '';
    displayName: 'Kernwaarden';
    icon: 'star';
  };
  attributes: {
    description: Schema.Attribute.Text & Schema.Attribute.Required;
    items: Schema.Attribute.Component<'elements.list-item-with-icon', true> &
      Schema.Attribute.Required &
      Schema.Attribute.SetMinMax<
        {
          max: 3;
          min: 1;
        },
        number
      >;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'elements.button': ElementsButton;
      'elements.list-item-with-icon': ElementsListItemWithIcon;
      'elements.social': ElementsSocial;
      'ui.hero': UiHero;
      'ui.kernwaarden': UiKernwaarden;
    }
  }
}
